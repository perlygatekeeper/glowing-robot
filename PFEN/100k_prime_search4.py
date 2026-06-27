#!/usr/bin/env -S python3 -u
import random
import time
import sys
import gmpy2
import inspect
import os
import json
import signal
import argparse  # NEW: for command-line argument parsing

# Modded to use Lucas test conditionally, now set to False and up the number of Trail Primes from
# 10_000 to 1_000_000
#
# further modified to allow restart of script by reading the output file from an earlier run.

sys.set_int_max_str_digits(10**6)  # Required to print/convert integers with up to 1,000,000 digits

VERBOSE    = True   # Set to True for detailed per-candidate output
USE_LUCAS  = False  # Set to True to run full Baillie-PSW (MR + Lucas-Selfridge)
                    # Set to False for Miller-Rabin k=5 only (faster, still extremely reliable)

# Confirm gmpy2 is actually being used — sanity check at startup:
print(f"gmpy2 version: {gmpy2.version()}")
n_test = gmpy2.mpz(123)
print(f"Type check: {type(n_test)}")  # Should show <class 'mpz'>

# ---------------------------------------------------------------------------
# NEW: Checkpoint Management
# ---------------------------------------------------------------------------
DEFAULT_CHECKPOINT = "prime_search_checkpoint_{describer}_{os.getpid()}.json"
_checkpoint_file = DEFAULT_CHECKPOINT  # Global for signal handler access
_current_state = None  # Global reference for signal handler

class SearchState:
    """Holds all mutable state needed to resume the prime search."""
    def __init__(self, n, wheel_steps, candidates_tested, candidates_sieved,
                 sieve_hit_counts, n_residues, residues_210, output_file):
        self.n = n  # gmpy2.mpz
        self.wheel_steps = wheel_steps
        self.candidates_tested = candidates_tested
        self.candidates_sieved = candidates_sieved
        self.sieve_hit_counts = sieve_hit_counts  # dict[int, int]
        self.n_residues = n_residues  # dict[int, int]
        self.residues_210 = residues_210  # dict[int, int] (constant, but stored for completeness)
        self.output_file = output_file
        self.found = False

def save_checkpoint(state, checkpoint_path):
    """Save current search state to checkpoint file using atomic write."""
    checkpoint = {
        "n": str(int(state.n)),  # Convert mpz to string for JSON compatibility
        "wheel_steps": state.wheel_steps,
        "candidates_tested": state.candidates_tested,
        "candidates_sieved": state.candidates_sieved,
        "sieve_hit_counts": {str(k): v for k, v in state.sieve_hit_counts.items()},
        "n_residues": {str(k): v for k, v in state.n_residues.items()},
        "output_file": state.output_file,
        "timestamp": time.time(),
        "gmpy2_version": gmpy2.version()
    }
    # Atomic write: write to temp file, then rename
    temp_path = checkpoint_path + ".tmp"
    with open(temp_path, 'w') as f:
        json.dump(checkpoint, f, indent=2)
    os.replace(temp_path, checkpoint_path)
    if VERBOSE:
        print(f"  [✓ Checkpoint saved] wheel_step={state.wheel_steps}, n=...{str(state.n)[-16:]}")

def load_checkpoint(checkpoint_path, trial_primes):
    """Load search state from checkpoint file if it exists and is valid."""
    if not os.path.exists(checkpoint_path):
        return None
    
    try:
        with open(checkpoint_path, 'r') as f:
            data = json.load(f)
        
        # Validate critical fields
        required = ["n", "wheel_steps", "n_residues", "output_file"]
        if not all(k in data for k in required):
            print(f"[Warning] Checkpoint missing required fields; starting fresh")
            return None
        
        # Reconstruct state
        n = gmpy2.mpz(int(data["n"]))
        wheel_steps = data["wheel_steps"]
        candidates_tested = data.get("candidates_tested", 0)
        candidates_sieved = data.get("candidates_sieved", 0)
        sieve_hit_counts = {int(k): v for k, v in data.get("sieve_hit_counts", {}).items()}
        n_residues = {int(k): v for k, v in data["n_residues"].items()}
        output_file = data["output_file"]
        
        # Rebuild residues_210 (it's constant, so recompute)
        residues_210 = {p: int(210 % p) for p in trial_primes}
        
        print(f"\n[✓ Resuming from checkpoint]")
        print(f"  Wheel steps:     {wheel_steps:,}")
        print(f"  Candidates tested: {candidates_tested:,}")
        print(f"  Candidates sieved: {candidates_sieved:,}")
        print(f"  Candidate        : {str(n)[:20]} ... {str(n)[-20:]}")
        print(f"  Output file:       {output_file}")
        print()
        
        return SearchState(
            n=n,
            wheel_steps=wheel_steps,
            candidates_tested=candidates_tested,
            candidates_sieved=candidates_sieved,
            sieve_hit_counts=sieve_hit_counts,
            n_residues=n_residues,
            residues_210=residues_210,
            output_file=output_file
        )
    except Exception as e:
        print(f"[Warning] Could not load checkpoint: {e}")
        print("  Starting fresh search...")
        return None

def signal_handler(sig, frame):
    """Handle Ctrl+C to save checkpoint before exiting gracefully."""
    global _current_state, _checkpoint_file
    print("\n[⚠ Interrupt received] Saving checkpoint before exit...")
    if _current_state and not _current_state.found:
        try:
            save_checkpoint(_current_state, _checkpoint_file)
            print(f"[✓ Checkpoint saved to {_checkpoint_file}]")
        except Exception as e:
            print(f"[✗ Failed to save checkpoint: {e}]")
    print("Exiting.")
    sys.exit(0)

# Register signal handler for graceful shutdown
signal.signal(signal.SIGINT, signal_handler)

# ---------------------------------------------------------------------------
# Command line argument parsing
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(
    description=f"Find {describer}-digit probable primes with restart capability",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument("--checkpoint", type=str, default=DEFAULT_CHECKPOINT,
                   help="Checkpoint file path for saving/resuming progress")
parser.add_argument("--output", type=str, default=None,
                   help="Output file for found primes (overrides auto-generated name)")
parser.add_argument("--no-resume", action="store_true",
                   help="Ignore existing checkpoint and start fresh")
parser.add_argument("--checkpoint-every", type=int, default=25,
                   help="Save checkpoint every N wheel steps")
args = parser.parse_args()

# Update global checkpoint path for signal handler
_checkpoint_file = args.checkpoint

# ---------------------------------------------------------------------------
# Utility
# ---------------------------------------------------------------------------

def time_primality_test(test_function, n, **kwargs):
    """Wrapper to time a primality test function. Passes any keyword args to the function."""
    start_time = time.time()
    sig = inspect.signature(test_function)
    valid_kwargs = {k: v for k, v in kwargs.items() if k in sig.parameters}
    result = test_function(n, **valid_kwargs)
    elapsed_time = time.time() - start_time
    if VERBOSE:
        print(f"  {test_function.__name__} took {elapsed_time:.6f}s -> {'probable prime' if result else 'composite'}")
    return result, elapsed_time


# ---------------------------------------------------------------------------
# Primality tests
# ---------------------------------------------------------------------------

def fermat_primality_test(n, k=5):
    """
    Fermat primality test on n using k iterations.
    WARNING: Susceptible to Carmichael numbers — use Miller-Rabin or BPSW in practice.
    Included for reference/comparison only.
    """
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False
    n = gmpy2.mpz(n)
    for _ in range(k):
        a = gmpy2.mpz(random.randint(2, int(n) - 2))
        if gmpy2.powmod(a, n - 1, n) != 1:
            return False
    return True


def miller_rabin_primality_test(n, k=5):
    """
    Miller-Rabin primality test on n using k random bases.
    Uses gmpy2.mpz throughout for maximum GMP-accelerated performance.
    """
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False

    n = gmpy2.mpz(n)

    # Write n-1 as 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2

    for _ in range(k):
        a = gmpy2.mpz(random.randint(2, int(n) - 2))
        x = gmpy2.powmod(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = gmpy2.powmod(x, 2, n)
            if x == n - 1:
                break
        else:
            return False  # Definitely composite
    return True  # Probably prime


def lucas_selfridge_test(n):
    """
    Strong Lucas probable prime test using Selfridge's parameter selection.
    This is the second half of the Baillie-PSW test.

    All big-integer arithmetic is done via gmpy2.mpz so GMP handles
    Karatsuba/FFT multiplication — critical for integers of 10,000 or more digits

    Algorithm:
      1. Find D via Selfridge's sequence 5,-7,9,-11,... until Jacobi(D,n)=-1
      2. Set P=1, Q=(1-D)/4
      3. Compute strong Lucas sequence U, V at index delta = n+1
         using the binary ladder method (double-and-add)
      4. Check strong Lucas conditions
    """
    n = gmpy2.mpz(n)

    # Step 1: Find D via Selfridge's sequence 5, -7, 9, -11, 13, ...
    D = gmpy2.mpz(5)
    sign = 1
    D_signed = gmpy2.mpz(0)
    for _ in range(100):
        D_signed = gmpy2.mpz(sign * D)
        j = gmpy2.jacobi(D_signed, n)
        if j == -1:
            break
        if j == 0 and abs(D_signed) < n:
            return False  # GCD(D, n) > 1 => composite
        D += 2
        sign = -sign
    else:
        return False  # Could not find suitable D (astronomically unlikely)

    P  = gmpy2.mpz(1)
    Q  = gmpy2.mpz((1 - int(D_signed)) // 4)  # Selfridge: Q = (1 - D) / 4

    # delta = n - Jacobi(D,n) = n + 1  (since Jacobi = -1)
    delta = n + 1

    # Write delta = 2^s * d_odd
    s = 0
    d_odd = delta
    while d_odd % 2 == 0:
        s += 1
        d_odd //= 2

    # --- Binary ladder (double-and-add) entirely in gmpy2.mpz ---
    # State: (U_k, V_k, Q^k mod n)

    def lucas_double(U, V, Qk):
        """Double index: (U_k, V_k, Qk) -> (U_{2k}, V_{2k}, Q^{2k})"""
        U2  = U * V % n
        V2  = (V * V - 2 * Qk) % n
        Qk2 = Qk * Qk % n
        return U2, V2, Qk2

    def lucas_add1(U, V, Qk):
        """Increment index by 1: (U_k, V_k, Qk) -> (U_{k+1}, V_{k+1}, Q^{k+1})"""
        U1 = (P * U + V) % n
        if U1 % 2 != 0:
            U1 += n
        U1 = gmpy2.divexact(U1, gmpy2.mpz(2))

        V1 = (D_signed * U + P * V) % n
        if V1 % 2 != 0:
            V1 += n
        V1 = gmpy2.divexact(V1, gmpy2.mpz(2))

        Qk1 = Qk * Q % n
        return U1, V1, Qk1

    # Initialise at index 1
    U  = gmpy2.mpz(1)
    V  = gmpy2.mpz(P)
    Qk = gmpy2.mpz(Q) % n

    # Walk the bits of d_odd from MSB-1 down to 0
    nbits = int(d_odd).bit_length()
    for i in range(nbits - 2, -1, -1):
        U, V, Qk = lucas_double(U, V, Qk)
        if (d_odd >> i) & 1:
            U, V, Qk = lucas_add1(U, V, Qk)

    # Strong Lucas primality conditions
    if U % n == 0 or V % n == 0:
        return True  # Probable prime

    for _ in range(s - 1):
        U, V, Qk = lucas_double(U, V, Qk)
        if V % n == 0:
            return True  # Probable prime

    return False  # Composite


def is_probable_prime(n):
    """
    Primality test dispatcher controlled by USE_LUCAS flag.

    USE_LUCAS=False : Miller-Rabin k=5 only
                      Fast; no known pseudoprimes at 100k or fewer digit scale.
    USE_LUCAS=True  : Full Baillie-PSW — MR k=3 + Lucas-Selfridge
                      Slower; no known counterexamples to BPSW at any scale.
    """
    if n < 2:
        return False
    if n in (2, 3, 5):
        return True
    if n % 2 == 0 or n % 3 == 0 or n % 5 == 0:
        return False

    if not USE_LUCAS:
        return miller_rabin_primality_test(n, k=5)

    # Full Baillie-PSW: MR first to cheaply eliminate most composites
    if not miller_rabin_primality_test(n, k=3):
        return False
    return lucas_selfridge_test(n)


# ---------------------------------------------------------------------------
# Wheel factorisation — mod 210 = 2 x 3 x 5 x 7
# The 48 residues coprime to 210.
# Note: 121=11², 143=11×13, 169=13², 187=11×17 are coprime to 210 but
# composite — they are filtered by TRIAL_PRIMES before any MR/Lucas call.
# ---------------------------------------------------------------------------
WHEEL_RESIDUES = [
      1,  11,  13,  17,  19,  23,  29,  31,  37,  41,  43,  47,
     53,  59,  61,  67,  71,  73,  79,  83,  89,  97, 101, 103,
    107, 109, 113, 121, 127, 131, 137, 139, 143, 149, 151, 157,
    163, 167, 169, 173, 179, 181, 187, 191, 193, 197, 199, 209
]

def build_trial_primes(limit):
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i*i::i] = bytearray(len(sieve[i*i::i]))
    return [i for i in range(11, limit + 1) if sieve[i]]

TRIAL_PRIMES = build_trial_primes(999_999)

# ---------------------------------------------------------------------------
# Initialize or restore search state
# ---------------------------------------------------------------------------
NUM_DIGITS   = 100_000
REPORT_EVERY = 70
run_start_time = time.time()

# Determine output file
if args.output:
    OUTPUT_FILE = args.output
else:
    # Auto-generate only if starting fresh
    OUTPUT_FILE = f"{describer}_probable_prime_{os.getpid()}.txt"

# Try to load checkpoint unless --no-resume is set
state = None
if not args.no_resume:
    state = load_checkpoint(_checkpoint_file, TRIAL_PRIMES)

if state:
    # Resume from checkpoint
    n = state.n
    wheel_steps = state.wheel_steps
    candidates_tested = state.candidates_tested
    candidates_sieved = state.candidates_sieved
    sieve_hit_counts = state.sieve_hit_counts
    n_residues = state.n_residues
    residues_210 = state.residues_210
    OUTPUT_FILE = state.output_file
    # Note: run_start_time is reset on resume; comment out next line to preserve original start time
    run_start_time = time.time()
else:
    # Fresh start - original initialization logic
    lower_num  = 10 ** (NUM_DIGITS - 2)
    upper_num  = 10 ** (NUM_DIGITS - 1) - 1
    last_digit = random.choice([1, 3, 7, 9])
    n          = random.randint(lower_num, upper_num)
    n          = n * 10 + last_digit
    n          = (n // 210) * 210
    wheel_steps       = 0
    START_RESIDUE     = 1
    n += 210 * wheel_steps
    n_residues       = {p: int(n   % p) for p in TRIAL_PRIMES}
    residues_210     = {p: int(210 % p) for p in TRIAL_PRIMES}
    sieve_hit_counts = {p: 0            for p in TRIAL_PRIMES}
    candidates_tested = 0
    candidates_sieved = 0

# Create SearchState object for signal handler access
_current_state = SearchState(
    n=n,
    wheel_steps=wheel_steps,
    candidates_tested=candidates_tested,
    candidates_sieved=candidates_sieved,
    sieve_hit_counts=sieve_hit_counts,
    n_residues=n_residues,
    residues_210=residues_210,
    output_file=OUTPUT_FILE
)

test_label = "Baillie-PSW (MR k=3 + Lucas-Selfridge)" if USE_LUCAS else "Miller-Rabin k=5"
print(f"Target:  {NUM_DIGITS}-digit probable prime")
print(f"Sieve:   {len(TRIAL_PRIMES)} trial primes (11..{TRIAL_PRIMES[-1]})")
print(f"Wheel:   mod 210, {len(WHEEL_RESIDUES)} residues per cycle")
print(f"Test:    {test_label}")
print(f"Start:   n = {int(n) // 10**(NUM_DIGITS-12)} .... {int(n) % 10**12}")
print(f"Verbose: {'ON' if VERBOSE else 'OFF'}")
print(f"Checkpoint: {_checkpoint_file} (every {args.checkpoint_every} wheel steps)")
print()

test_time_total   = 0.0
found = False

# Open output file: append if resuming, write if fresh
file_mode = "a" if (state and not args.no_resume) else "w"

with open(OUTPUT_FILE, file_mode) as f:
    while not found:
        wheel_steps += 1
        f.write(f"root candidate:\n{n}\n")

        for r in WHEEL_RESIDUES:
            sieved_out = False
            for p in TRIAL_PRIMES:
                if (n_residues[p] + r) % p == 0:
                    sieve_hit_counts[p] += 1
                    sieved_out = True
                    candidates_sieved += 1
                    sieve = p
                    break
            if sieved_out:
                if VERBOSE:
                    print(f"  r={r}: sieved by {p}")
                continue

            candidate = n + r
            candidates_tested += 1

            if VERBOSE:
                print(f"  r={r}: running {test_label} on ...{int(candidate) % 10**8}")

            result, elapsed = time_primality_test(is_probable_prime, candidate)
            test_time_total += elapsed

            if result:
                elapsed_total = time.time() - run_start_time
                print(f"\n*** Probable prime found!")
                print(f"    Test             : {test_label}")
                print(f"    Wheel step       : {wheel_steps},  residue: {r}")
                print(f"    Candidates tested: {candidates_tested}")
                print(f"    Candidates sieved: {candidates_sieved}")
                print(f"    Total test time  : {test_time_total:.2f}s")
                print(f"    Wall time        : {elapsed_total:.1f}s")
                print(f"    Candidate        : {str(candidate)[:20]} ... {str(candidate)[-20:]}")
                print(f"    OUTPUT to        : {OUTPUT_FILE}")
                f.write(f"{candidate}\n")
                f.flush()  # Ensure prime is written immediately
                top_sieves = sorted(sieve_hit_counts.items(), key=lambda x: x[1], reverse=True)[:30]
                print("Top 30 sieve primes:")
                for p, count in top_sieves:
                    print(f"  {p:>5}: {count:>8} hits")
                
                # Save final checkpoint
                _current_state.found = True
                save_checkpoint(_current_state, _checkpoint_file)
                found = True
                break

        if not found:
            # Update n and residues for next wheel cycle
            n += 210
            for p in TRIAL_PRIMES:
                n_residues[p] = (n_residues[p] + residues_210[p]) % p
            
            # Update global state for signal handler
            _current_state.n = n
            _current_state.wheel_steps = wheel_steps
            _current_state.candidates_tested = candidates_tested
            _current_state.candidates_sieved = candidates_sieved
            _current_state.sieve_hit_counts = sieve_hit_counts
            _current_state.n_residues = n_residues

            # Periodic checkpoint save
            if wheel_steps < 2 or wheel_steps % args.checkpoint_every == 0:
                save_checkpoint(_current_state, _checkpoint_file)

            if True or (wheel_steps % REPORT_EVERY == 0):
                elapsed_total = time.time() - run_start_time
                avg = test_time_total / candidates_tested if candidates_tested else 0
                print(
                    f"---------------------------------------------------------------------------\n"
                    f" [wheel step {wheel_steps:>6}] covering {wheel_steps*210:>7} integers\n"
                    f" | candidates sieved: {candidates_sieved:>6} per wheel: {candidates_sieved/wheel_steps:>6.2f}\n"
                    f" | candidates tested: {candidates_tested:>6} per wheel: {candidates_tested/wheel_steps:>6.2f}\n"
                    f" | avg test: {avg:.3f}s\n | total test: {test_time_total:.1f}s\n"
                    f" | wall time: {elapsed_total:.1f}s"
                )

# Final checkpoint save if exited without finding prime
if not found:
    save_checkpoint(_current_state, _checkpoint_file)

print("Search complete." if found else "Search ended without a find.")
