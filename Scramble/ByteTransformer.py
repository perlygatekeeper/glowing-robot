#!/opt/local/bin/python
# Can you help me begin development of an object-oriented module in
# python for performing transformations on length 8 bytearrays

import sys
import io
import functools
import random

class ByteTransformer:
    shift_mask_left  = [ 0b00000000, 0b10000000, 0b11000000, 0b11100000, 0b11110000, 0b11111000, 0b11111100, 0b11111110 ]
    shift_mask_right = [ 0b11111111, 0b01111111, 0b00111111, 0b00011111, 0b00001111, 0b00000111, 0b00000011, 0b00000001 ]
    bit_sensor       = [ 0b00000001, 0b00000010, 0b00000100, 0b00001000, 0b00010000, 0b00100000, 0b01000000, 0b10000000 ]
    byte_transforms = {
      0x00: { 'bit_string': '00000000', 'hexdecimal': '0x00', 'reversed': 0x00, 'inverted': 0xFF, 'parity': 0, 'ones': 0, '00': 4, '01': 0, '10': 0, '11': 0 },
      0x01: { 'bit_string': '00000001', 'hexdecimal': '0x01', 'reversed': 0x80, 'inverted': 0xFE, 'parity': 1, 'ones': 1, '00': 3, '01': 1, '10': 0, '11': 0 },
      0x02: { 'bit_string': '00000010', 'hexdecimal': '0x02', 'reversed': 0x40, 'inverted': 0xFD, 'parity': 1, 'ones': 1, '00': 3, '01': 0, '10': 1, '11': 0 },
      0x03: { 'bit_string': '00000011', 'hexdecimal': '0x03', 'reversed': 0xC0, 'inverted': 0xFC, 'parity': 0, 'ones': 2, '00': 3, '01': 0, '10': 0, '11': 1 },
      0x04: { 'bit_string': '00000100', 'hexdecimal': '0x04', 'reversed': 0x20, 'inverted': 0xFB, 'parity': 1, 'ones': 1, '00': 3, '01': 1, '10': 0, '11': 0 },
      0x05: { 'bit_string': '00000101', 'hexdecimal': '0x05', 'reversed': 0xA0, 'inverted': 0xFA, 'parity': 0, 'ones': 2, '00': 2, '01': 2, '10': 0, '11': 0 },
      0x06: { 'bit_string': '00000110', 'hexdecimal': '0x06', 'reversed': 0x60, 'inverted': 0xF9, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x07: { 'bit_string': '00000111', 'hexdecimal': '0x07', 'reversed': 0xE0, 'inverted': 0xF8, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x08: { 'bit_string': '00001000', 'hexdecimal': '0x08', 'reversed': 0x10, 'inverted': 0xF7, 'parity': 1, 'ones': 1, '00': 3, '01': 0, '10': 1, '11': 0 },
      0x09: { 'bit_string': '00001001', 'hexdecimal': '0x09', 'reversed': 0x90, 'inverted': 0xF6, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x0A: { 'bit_string': '00001010', 'hexdecimal': '0x0A', 'reversed': 0x50, 'inverted': 0xF5, 'parity': 0, 'ones': 2, '00': 2, '01': 0, '10': 2, '11': 0 },
      0x0B: { 'bit_string': '00001011', 'hexdecimal': '0x0B', 'reversed': 0xD0, 'inverted': 0xF4, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x0C: { 'bit_string': '00001100', 'hexdecimal': '0x0C', 'reversed': 0x30, 'inverted': 0xF3, 'parity': 0, 'ones': 2, '00': 3, '01': 0, '10': 0, '11': 1 },
      0x0D: { 'bit_string': '00001101', 'hexdecimal': '0x0D', 'reversed': 0xB0, 'inverted': 0xF2, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x0E: { 'bit_string': '00001110', 'hexdecimal': '0x0E', 'reversed': 0x70, 'inverted': 0xF1, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x0F: { 'bit_string': '00001111', 'hexdecimal': '0x0F', 'reversed': 0xF0, 'inverted': 0xF0, 'parity': 0, 'ones': 4, '00': 2, '01': 0, '10': 0, '11': 2 },
      0x10: { 'bit_string': '00010000', 'hexdecimal': '0x10', 'reversed': 0x08, 'inverted': 0xEF, 'parity': 1, 'ones': 1, '00': 3, '01': 1, '10': 0, '11': 0 },
      0x11: { 'bit_string': '00010001', 'hexdecimal': '0x11', 'reversed': 0x88, 'inverted': 0xEE, 'parity': 0, 'ones': 2, '00': 2, '01': 2, '10': 0, '11': 0 },
      0x12: { 'bit_string': '00010010', 'hexdecimal': '0x12', 'reversed': 0x48, 'inverted': 0xED, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x13: { 'bit_string': '00010011', 'hexdecimal': '0x13', 'reversed': 0xC8, 'inverted': 0xEC, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x14: { 'bit_string': '00010100', 'hexdecimal': '0x14', 'reversed': 0x28, 'inverted': 0xEB, 'parity': 0, 'ones': 2, '00': 2, '01': 2, '10': 0, '11': 0 },
      0x15: { 'bit_string': '00010101', 'hexdecimal': '0x15', 'reversed': 0xA8, 'inverted': 0xEA, 'parity': 1, 'ones': 3, '00': 1, '01': 3, '10': 0, '11': 0 },
      0x16: { 'bit_string': '00010110', 'hexdecimal': '0x16', 'reversed': 0x68, 'inverted': 0xE9, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x17: { 'bit_string': '00010111', 'hexdecimal': '0x17', 'reversed': 0xE8, 'inverted': 0xE8, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x18: { 'bit_string': '00011000', 'hexdecimal': '0x18', 'reversed': 0x18, 'inverted': 0xE7, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x19: { 'bit_string': '00011001', 'hexdecimal': '0x19', 'reversed': 0x98, 'inverted': 0xE6, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x1A: { 'bit_string': '00011010', 'hexdecimal': '0x1A', 'reversed': 0x58, 'inverted': 0xE5, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x1B: { 'bit_string': '00011011', 'hexdecimal': '0x1B', 'reversed': 0xD8, 'inverted': 0xE4, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x1C: { 'bit_string': '00011100', 'hexdecimal': '0x1C', 'reversed': 0x38, 'inverted': 0xE3, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x1D: { 'bit_string': '00011101', 'hexdecimal': '0x1D', 'reversed': 0xB8, 'inverted': 0xE2, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x1E: { 'bit_string': '00011110', 'hexdecimal': '0x1E', 'reversed': 0x78, 'inverted': 0xE1, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x1F: { 'bit_string': '00011111', 'hexdecimal': '0x1F', 'reversed': 0xF8, 'inverted': 0xE0, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0x20: { 'bit_string': '00100000', 'hexdecimal': '0x20', 'reversed': 0x04, 'inverted': 0xDF, 'parity': 1, 'ones': 1, '00': 3, '01': 0, '10': 1, '11': 0 },
      0x21: { 'bit_string': '00100001', 'hexdecimal': '0x21', 'reversed': 0x84, 'inverted': 0xDE, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x22: { 'bit_string': '00100010', 'hexdecimal': '0x22', 'reversed': 0x44, 'inverted': 0xDD, 'parity': 0, 'ones': 2, '00': 2, '01': 0, '10': 2, '11': 0 },
      0x23: { 'bit_string': '00100011', 'hexdecimal': '0x23', 'reversed': 0xC4, 'inverted': 0xDC, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x24: { 'bit_string': '00100100', 'hexdecimal': '0x24', 'reversed': 0x24, 'inverted': 0xDB, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x25: { 'bit_string': '00100101', 'hexdecimal': '0x25', 'reversed': 0xA4, 'inverted': 0xDA, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x26: { 'bit_string': '00100110', 'hexdecimal': '0x26', 'reversed': 0x64, 'inverted': 0xD9, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x27: { 'bit_string': '00100111', 'hexdecimal': '0x27', 'reversed': 0xE4, 'inverted': 0xD8, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x28: { 'bit_string': '00101000', 'hexdecimal': '0x28', 'reversed': 0x14, 'inverted': 0xD7, 'parity': 0, 'ones': 2, '00': 2, '01': 0, '10': 2, '11': 0 },
      0x29: { 'bit_string': '00101001', 'hexdecimal': '0x29', 'reversed': 0x94, 'inverted': 0xD6, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x2A: { 'bit_string': '00101010', 'hexdecimal': '0x2A', 'reversed': 0x54, 'inverted': 0xD5, 'parity': 1, 'ones': 3, '00': 1, '01': 0, '10': 3, '11': 0 },
      0x2B: { 'bit_string': '00101011', 'hexdecimal': '0x2B', 'reversed': 0xD4, 'inverted': 0xD4, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0x2C: { 'bit_string': '00101100', 'hexdecimal': '0x2C', 'reversed': 0x34, 'inverted': 0xD3, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x2D: { 'bit_string': '00101101', 'hexdecimal': '0x2D', 'reversed': 0xB4, 'inverted': 0xD2, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x2E: { 'bit_string': '00101110', 'hexdecimal': '0x2E', 'reversed': 0x74, 'inverted': 0xD1, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0x2F: { 'bit_string': '00101111', 'hexdecimal': '0x2F', 'reversed': 0xF4, 'inverted': 0xD0, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0x30: { 'bit_string': '00110000', 'hexdecimal': '0x30', 'reversed': 0x0C, 'inverted': 0xCF, 'parity': 0, 'ones': 2, '00': 3, '01': 0, '10': 0, '11': 1 },
      0x31: { 'bit_string': '00110001', 'hexdecimal': '0x31', 'reversed': 0x8C, 'inverted': 0xCE, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x32: { 'bit_string': '00110010', 'hexdecimal': '0x32', 'reversed': 0x4C, 'inverted': 0xCD, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x33: { 'bit_string': '00110011', 'hexdecimal': '0x33', 'reversed': 0xCC, 'inverted': 0xCC, 'parity': 0, 'ones': 4, '00': 2, '01': 0, '10': 0, '11': 2 },
      0x34: { 'bit_string': '00110100', 'hexdecimal': '0x34', 'reversed': 0x2C, 'inverted': 0xCB, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x35: { 'bit_string': '00110101', 'hexdecimal': '0x35', 'reversed': 0xAC, 'inverted': 0xCA, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x36: { 'bit_string': '00110110', 'hexdecimal': '0x36', 'reversed': 0x6C, 'inverted': 0xC9, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x37: { 'bit_string': '00110111', 'hexdecimal': '0x37', 'reversed': 0xEC, 'inverted': 0xC8, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0x38: { 'bit_string': '00111000', 'hexdecimal': '0x38', 'reversed': 0x1C, 'inverted': 0xC7, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x39: { 'bit_string': '00111001', 'hexdecimal': '0x39', 'reversed': 0x9C, 'inverted': 0xC6, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x3A: { 'bit_string': '00111010', 'hexdecimal': '0x3A', 'reversed': 0x5C, 'inverted': 0xC5, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0x3B: { 'bit_string': '00111011', 'hexdecimal': '0x3B', 'reversed': 0xDC, 'inverted': 0xC4, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0x3C: { 'bit_string': '00111100', 'hexdecimal': '0x3C', 'reversed': 0x3C, 'inverted': 0xC3, 'parity': 0, 'ones': 4, '00': 2, '01': 0, '10': 0, '11': 2 },
      0x3D: { 'bit_string': '00111101', 'hexdecimal': '0x3D', 'reversed': 0xBC, 'inverted': 0xC2, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0x3E: { 'bit_string': '00111110', 'hexdecimal': '0x3E', 'reversed': 0x7C, 'inverted': 0xC1, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0x3F: { 'bit_string': '00111111', 'hexdecimal': '0x3F', 'reversed': 0xFC, 'inverted': 0xC0, 'parity': 0, 'ones': 6, '00': 1, '01': 0, '10': 0, '11': 3 },
      0x40: { 'bit_string': '01000000', 'hexdecimal': '0x40', 'reversed': 0x02, 'inverted': 0xBF, 'parity': 1, 'ones': 1, '00': 3, '01': 1, '10': 0, '11': 0 },
      0x41: { 'bit_string': '01000001', 'hexdecimal': '0x41', 'reversed': 0x82, 'inverted': 0xBE, 'parity': 0, 'ones': 2, '00': 2, '01': 2, '10': 0, '11': 0 },
      0x42: { 'bit_string': '01000010', 'hexdecimal': '0x42', 'reversed': 0x42, 'inverted': 0xBD, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x43: { 'bit_string': '01000011', 'hexdecimal': '0x43', 'reversed': 0xC2, 'inverted': 0xBC, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x44: { 'bit_string': '01000100', 'hexdecimal': '0x44', 'reversed': 0x22, 'inverted': 0xBB, 'parity': 0, 'ones': 2, '00': 2, '01': 2, '10': 0, '11': 0 },
      0x45: { 'bit_string': '01000101', 'hexdecimal': '0x45', 'reversed': 0xA2, 'inverted': 0xBA, 'parity': 1, 'ones': 3, '00': 1, '01': 3, '10': 0, '11': 0 },
      0x46: { 'bit_string': '01000110', 'hexdecimal': '0x46', 'reversed': 0x62, 'inverted': 0xB9, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x47: { 'bit_string': '01000111', 'hexdecimal': '0x47', 'reversed': 0xE2, 'inverted': 0xB8, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x48: { 'bit_string': '01001000', 'hexdecimal': '0x48', 'reversed': 0x12, 'inverted': 0xB7, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x49: { 'bit_string': '01001001', 'hexdecimal': '0x49', 'reversed': 0x92, 'inverted': 0xB6, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x4A: { 'bit_string': '01001010', 'hexdecimal': '0x4A', 'reversed': 0x52, 'inverted': 0xB5, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x4B: { 'bit_string': '01001011', 'hexdecimal': '0x4B', 'reversed': 0xD2, 'inverted': 0xB4, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x4C: { 'bit_string': '01001100', 'hexdecimal': '0x4C', 'reversed': 0x32, 'inverted': 0xB3, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x4D: { 'bit_string': '01001101', 'hexdecimal': '0x4D', 'reversed': 0xB2, 'inverted': 0xB2, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x4E: { 'bit_string': '01001110', 'hexdecimal': '0x4E', 'reversed': 0x72, 'inverted': 0xB1, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x4F: { 'bit_string': '01001111', 'hexdecimal': '0x4F', 'reversed': 0xF2, 'inverted': 0xB0, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0x50: { 'bit_string': '01010000', 'hexdecimal': '0x50', 'reversed': 0x0A, 'inverted': 0xAF, 'parity': 0, 'ones': 2, '00': 2, '01': 2, '10': 0, '11': 0 },
      0x51: { 'bit_string': '01010001', 'hexdecimal': '0x51', 'reversed': 0x8A, 'inverted': 0xAE, 'parity': 1, 'ones': 3, '00': 1, '01': 3, '10': 0, '11': 0 },
      0x52: { 'bit_string': '01010010', 'hexdecimal': '0x52', 'reversed': 0x4A, 'inverted': 0xAD, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x53: { 'bit_string': '01010011', 'hexdecimal': '0x53', 'reversed': 0xCA, 'inverted': 0xAC, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x54: { 'bit_string': '01010100', 'hexdecimal': '0x54', 'reversed': 0x2A, 'inverted': 0xAB, 'parity': 1, 'ones': 3, '00': 1, '01': 3, '10': 0, '11': 0 },
      0x55: { 'bit_string': '01010101', 'hexdecimal': '0x55', 'reversed': 0xAA, 'inverted': 0xAA, 'parity': 0, 'ones': 4, '00': 0, '01': 4, '10': 0, '11': 0 },
      0x56: { 'bit_string': '01010110', 'hexdecimal': '0x56', 'reversed': 0x6A, 'inverted': 0xA9, 'parity': 0, 'ones': 4, '00': 0, '01': 3, '10': 1, '11': 0 },
      0x57: { 'bit_string': '01010111', 'hexdecimal': '0x57', 'reversed': 0xEA, 'inverted': 0xA8, 'parity': 1, 'ones': 5, '00': 0, '01': 3, '10': 0, '11': 1 },
      0x58: { 'bit_string': '01011000', 'hexdecimal': '0x58', 'reversed': 0x1A, 'inverted': 0xA7, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x59: { 'bit_string': '01011001', 'hexdecimal': '0x59', 'reversed': 0x9A, 'inverted': 0xA6, 'parity': 0, 'ones': 4, '00': 0, '01': 3, '10': 1, '11': 0 },
      0x5A: { 'bit_string': '01011010', 'hexdecimal': '0x5A', 'reversed': 0x5A, 'inverted': 0xA5, 'parity': 0, 'ones': 4, '00': 0, '01': 2, '10': 2, '11': 0 },
      0x5B: { 'bit_string': '01011011', 'hexdecimal': '0x5B', 'reversed': 0xDA, 'inverted': 0xA4, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x5C: { 'bit_string': '01011100', 'hexdecimal': '0x5C', 'reversed': 0x3A, 'inverted': 0xA3, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x5D: { 'bit_string': '01011101', 'hexdecimal': '0x5D', 'reversed': 0xBA, 'inverted': 0xA2, 'parity': 1, 'ones': 5, '00': 0, '01': 3, '10': 0, '11': 1 },
      0x5E: { 'bit_string': '01011110', 'hexdecimal': '0x5E', 'reversed': 0x7A, 'inverted': 0xA1, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x5F: { 'bit_string': '01011111', 'hexdecimal': '0x5F', 'reversed': 0xFA, 'inverted': 0xA0, 'parity': 0, 'ones': 6, '00': 0, '01': 2, '10': 0, '11': 2 },
      0x60: { 'bit_string': '01100000', 'hexdecimal': '0x60', 'reversed': 0x06, 'inverted': 0x9F, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x61: { 'bit_string': '01100001', 'hexdecimal': '0x61', 'reversed': 0x86, 'inverted': 0x9E, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x62: { 'bit_string': '01100010', 'hexdecimal': '0x62', 'reversed': 0x46, 'inverted': 0x9D, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x63: { 'bit_string': '01100011', 'hexdecimal': '0x63', 'reversed': 0xC6, 'inverted': 0x9C, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x64: { 'bit_string': '01100100', 'hexdecimal': '0x64', 'reversed': 0x26, 'inverted': 0x9B, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x65: { 'bit_string': '01100101', 'hexdecimal': '0x65', 'reversed': 0xA6, 'inverted': 0x9A, 'parity': 0, 'ones': 4, '00': 0, '01': 3, '10': 1, '11': 0 },
      0x66: { 'bit_string': '01100110', 'hexdecimal': '0x66', 'reversed': 0x66, 'inverted': 0x99, 'parity': 0, 'ones': 4, '00': 0, '01': 2, '10': 2, '11': 0 },
      0x67: { 'bit_string': '01100111', 'hexdecimal': '0x67', 'reversed': 0xE6, 'inverted': 0x98, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x68: { 'bit_string': '01101000', 'hexdecimal': '0x68', 'reversed': 0x16, 'inverted': 0x97, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x69: { 'bit_string': '01101001', 'hexdecimal': '0x69', 'reversed': 0x96, 'inverted': 0x96, 'parity': 0, 'ones': 4, '00': 0, '01': 2, '10': 2, '11': 0 },
      0x6A: { 'bit_string': '01101010', 'hexdecimal': '0x6A', 'reversed': 0x56, 'inverted': 0x95, 'parity': 0, 'ones': 4, '00': 0, '01': 1, '10': 3, '11': 0 },
      0x6B: { 'bit_string': '01101011', 'hexdecimal': '0x6B', 'reversed': 0xD6, 'inverted': 0x94, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0x6C: { 'bit_string': '01101100', 'hexdecimal': '0x6C', 'reversed': 0x36, 'inverted': 0x93, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x6D: { 'bit_string': '01101101', 'hexdecimal': '0x6D', 'reversed': 0xB6, 'inverted': 0x92, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x6E: { 'bit_string': '01101110', 'hexdecimal': '0x6E', 'reversed': 0x76, 'inverted': 0x91, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0x6F: { 'bit_string': '01101111', 'hexdecimal': '0x6F', 'reversed': 0xF6, 'inverted': 0x90, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0x70: { 'bit_string': '01110000', 'hexdecimal': '0x70', 'reversed': 0x0E, 'inverted': 0x8F, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0x71: { 'bit_string': '01110001', 'hexdecimal': '0x71', 'reversed': 0x8E, 'inverted': 0x8E, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x72: { 'bit_string': '01110010', 'hexdecimal': '0x72', 'reversed': 0x4E, 'inverted': 0x8D, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x73: { 'bit_string': '01110011', 'hexdecimal': '0x73', 'reversed': 0xCE, 'inverted': 0x8C, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0x74: { 'bit_string': '01110100', 'hexdecimal': '0x74', 'reversed': 0x2E, 'inverted': 0x8B, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0x75: { 'bit_string': '01110101', 'hexdecimal': '0x75', 'reversed': 0xAE, 'inverted': 0x8A, 'parity': 1, 'ones': 5, '00': 0, '01': 3, '10': 0, '11': 1 },
      0x76: { 'bit_string': '01110110', 'hexdecimal': '0x76', 'reversed': 0x6E, 'inverted': 0x89, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x77: { 'bit_string': '01110111', 'hexdecimal': '0x77', 'reversed': 0xEE, 'inverted': 0x88, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0x78: { 'bit_string': '01111000', 'hexdecimal': '0x78', 'reversed': 0x1E, 'inverted': 0x87, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x79: { 'bit_string': '01111001', 'hexdecimal': '0x79', 'reversed': 0x9E, 'inverted': 0x86, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x7A: { 'bit_string': '01111010', 'hexdecimal': '0x7A', 'reversed': 0x5E, 'inverted': 0x85, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0x7B: { 'bit_string': '01111011', 'hexdecimal': '0x7B', 'reversed': 0xDE, 'inverted': 0x84, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0x7C: { 'bit_string': '01111100', 'hexdecimal': '0x7C', 'reversed': 0x3E, 'inverted': 0x83, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0x7D: { 'bit_string': '01111101', 'hexdecimal': '0x7D', 'reversed': 0xBE, 'inverted': 0x82, 'parity': 0, 'ones': 6, '00': 0, '01': 2, '10': 0, '11': 2 },
      0x7E: { 'bit_string': '01111110', 'hexdecimal': '0x7E', 'reversed': 0x7E, 'inverted': 0x81, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0x7F: { 'bit_string': '01111111', 'hexdecimal': '0x7F', 'reversed': 0xFE, 'inverted': 0x80, 'parity': 1, 'ones': 7, '00': 0, '01': 1, '10': 0, '11': 3 },
      0x80: { 'bit_string': '10000000', 'hexdecimal': '0x80', 'reversed': 0x01, 'inverted': 0x7F, 'parity': 1, 'ones': 1, '00': 3, '01': 0, '10': 1, '11': 0 },
      0x81: { 'bit_string': '10000001', 'hexdecimal': '0x81', 'reversed': 0x81, 'inverted': 0x7E, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x82: { 'bit_string': '10000010', 'hexdecimal': '0x82', 'reversed': 0x41, 'inverted': 0x7D, 'parity': 0, 'ones': 2, '00': 2, '01': 0, '10': 2, '11': 0 },
      0x83: { 'bit_string': '10000011', 'hexdecimal': '0x83', 'reversed': 0xC1, 'inverted': 0x7C, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x84: { 'bit_string': '10000100', 'hexdecimal': '0x84', 'reversed': 0x21, 'inverted': 0x7B, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x85: { 'bit_string': '10000101', 'hexdecimal': '0x85', 'reversed': 0xA1, 'inverted': 0x7A, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x86: { 'bit_string': '10000110', 'hexdecimal': '0x86', 'reversed': 0x61, 'inverted': 0x79, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x87: { 'bit_string': '10000111', 'hexdecimal': '0x87', 'reversed': 0xE1, 'inverted': 0x78, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x88: { 'bit_string': '10001000', 'hexdecimal': '0x88', 'reversed': 0x11, 'inverted': 0x77, 'parity': 0, 'ones': 2, '00': 2, '01': 0, '10': 2, '11': 0 },
      0x89: { 'bit_string': '10001001', 'hexdecimal': '0x89', 'reversed': 0x91, 'inverted': 0x76, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x8A: { 'bit_string': '10001010', 'hexdecimal': '0x8A', 'reversed': 0x51, 'inverted': 0x75, 'parity': 1, 'ones': 3, '00': 1, '01': 0, '10': 3, '11': 0 },
      0x8B: { 'bit_string': '10001011', 'hexdecimal': '0x8B', 'reversed': 0xD1, 'inverted': 0x74, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0x8C: { 'bit_string': '10001100', 'hexdecimal': '0x8C', 'reversed': 0x31, 'inverted': 0x73, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0x8D: { 'bit_string': '10001101', 'hexdecimal': '0x8D', 'reversed': 0xB1, 'inverted': 0x72, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x8E: { 'bit_string': '10001110', 'hexdecimal': '0x8E', 'reversed': 0x71, 'inverted': 0x71, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0x8F: { 'bit_string': '10001111', 'hexdecimal': '0x8F', 'reversed': 0xF1, 'inverted': 0x70, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0x90: { 'bit_string': '10010000', 'hexdecimal': '0x90', 'reversed': 0x09, 'inverted': 0x6F, 'parity': 0, 'ones': 2, '00': 2, '01': 1, '10': 1, '11': 0 },
      0x91: { 'bit_string': '10010001', 'hexdecimal': '0x91', 'reversed': 0x89, 'inverted': 0x6E, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x92: { 'bit_string': '10010010', 'hexdecimal': '0x92', 'reversed': 0x49, 'inverted': 0x6D, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x93: { 'bit_string': '10010011', 'hexdecimal': '0x93', 'reversed': 0xC9, 'inverted': 0x6C, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x94: { 'bit_string': '10010100', 'hexdecimal': '0x94', 'reversed': 0x29, 'inverted': 0x6B, 'parity': 1, 'ones': 3, '00': 1, '01': 2, '10': 1, '11': 0 },
      0x95: { 'bit_string': '10010101', 'hexdecimal': '0x95', 'reversed': 0xA9, 'inverted': 0x6A, 'parity': 0, 'ones': 4, '00': 0, '01': 3, '10': 1, '11': 0 },
      0x96: { 'bit_string': '10010110', 'hexdecimal': '0x96', 'reversed': 0x69, 'inverted': 0x69, 'parity': 0, 'ones': 4, '00': 0, '01': 2, '10': 2, '11': 0 },
      0x97: { 'bit_string': '10010111', 'hexdecimal': '0x97', 'reversed': 0xE9, 'inverted': 0x68, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x98: { 'bit_string': '10011000', 'hexdecimal': '0x98', 'reversed': 0x19, 'inverted': 0x67, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0x99: { 'bit_string': '10011001', 'hexdecimal': '0x99', 'reversed': 0x99, 'inverted': 0x66, 'parity': 0, 'ones': 4, '00': 0, '01': 2, '10': 2, '11': 0 },
      0x9A: { 'bit_string': '10011010', 'hexdecimal': '0x9A', 'reversed': 0x59, 'inverted': 0x65, 'parity': 0, 'ones': 4, '00': 0, '01': 1, '10': 3, '11': 0 },
      0x9B: { 'bit_string': '10011011', 'hexdecimal': '0x9B', 'reversed': 0xD9, 'inverted': 0x64, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0x9C: { 'bit_string': '10011100', 'hexdecimal': '0x9C', 'reversed': 0x39, 'inverted': 0x63, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0x9D: { 'bit_string': '10011101', 'hexdecimal': '0x9D', 'reversed': 0xB9, 'inverted': 0x62, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0x9E: { 'bit_string': '10011110', 'hexdecimal': '0x9E', 'reversed': 0x79, 'inverted': 0x61, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0x9F: { 'bit_string': '10011111', 'hexdecimal': '0x9F', 'reversed': 0xF9, 'inverted': 0x60, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xA0: { 'bit_string': '10100000', 'hexdecimal': '0xA0', 'reversed': 0x05, 'inverted': 0x5F, 'parity': 0, 'ones': 2, '00': 2, '01': 0, '10': 2, '11': 0 },
      0xA1: { 'bit_string': '10100001', 'hexdecimal': '0xA1', 'reversed': 0x85, 'inverted': 0x5E, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0xA2: { 'bit_string': '10100010', 'hexdecimal': '0xA2', 'reversed': 0x45, 'inverted': 0x5D, 'parity': 1, 'ones': 3, '00': 1, '01': 0, '10': 3, '11': 0 },
      0xA3: { 'bit_string': '10100011', 'hexdecimal': '0xA3', 'reversed': 0xC5, 'inverted': 0x5C, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0xA4: { 'bit_string': '10100100', 'hexdecimal': '0xA4', 'reversed': 0x25, 'inverted': 0x5B, 'parity': 1, 'ones': 3, '00': 1, '01': 1, '10': 2, '11': 0 },
      0xA5: { 'bit_string': '10100101', 'hexdecimal': '0xA5', 'reversed': 0xA5, 'inverted': 0x5A, 'parity': 0, 'ones': 4, '00': 0, '01': 2, '10': 2, '11': 0 },
      0xA6: { 'bit_string': '10100110', 'hexdecimal': '0xA6', 'reversed': 0x65, 'inverted': 0x59, 'parity': 0, 'ones': 4, '00': 0, '01': 1, '10': 3, '11': 0 },
      0xA7: { 'bit_string': '10100111', 'hexdecimal': '0xA7', 'reversed': 0xE5, 'inverted': 0x58, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0xA8: { 'bit_string': '10101000', 'hexdecimal': '0xA8', 'reversed': 0x15, 'inverted': 0x57, 'parity': 1, 'ones': 3, '00': 1, '01': 0, '10': 3, '11': 0 },
      0xA9: { 'bit_string': '10101001', 'hexdecimal': '0xA9', 'reversed': 0x95, 'inverted': 0x56, 'parity': 0, 'ones': 4, '00': 0, '01': 1, '10': 3, '11': 0 },
      0xAA: { 'bit_string': '10101010', 'hexdecimal': '0xAA', 'reversed': 0x55, 'inverted': 0x55, 'parity': 0, 'ones': 4, '00': 0, '01': 0, '10': 4, '11': 0 },
      0xAB: { 'bit_string': '10101011', 'hexdecimal': '0xAB', 'reversed': 0xD5, 'inverted': 0x54, 'parity': 1, 'ones': 5, '00': 0, '01': 0, '10': 3, '11': 1 },
      0xAC: { 'bit_string': '10101100', 'hexdecimal': '0xAC', 'reversed': 0x35, 'inverted': 0x53, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0xAD: { 'bit_string': '10101101', 'hexdecimal': '0xAD', 'reversed': 0xB5, 'inverted': 0x52, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0xAE: { 'bit_string': '10101110', 'hexdecimal': '0xAE', 'reversed': 0x75, 'inverted': 0x51, 'parity': 1, 'ones': 5, '00': 0, '01': 0, '10': 3, '11': 1 },
      0xAF: { 'bit_string': '10101111', 'hexdecimal': '0xAF', 'reversed': 0xF5, 'inverted': 0x50, 'parity': 0, 'ones': 6, '00': 0, '01': 0, '10': 2, '11': 2 },
      0xB0: { 'bit_string': '10110000', 'hexdecimal': '0xB0', 'reversed': 0x0D, 'inverted': 0x4F, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0xB1: { 'bit_string': '10110001', 'hexdecimal': '0xB1', 'reversed': 0x8D, 'inverted': 0x4E, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xB2: { 'bit_string': '10110010', 'hexdecimal': '0xB2', 'reversed': 0x4D, 'inverted': 0x4D, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0xB3: { 'bit_string': '10110011', 'hexdecimal': '0xB3', 'reversed': 0xCD, 'inverted': 0x4C, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xB4: { 'bit_string': '10110100', 'hexdecimal': '0xB4', 'reversed': 0x2D, 'inverted': 0x4B, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xB5: { 'bit_string': '10110101', 'hexdecimal': '0xB5', 'reversed': 0xAD, 'inverted': 0x4A, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0xB6: { 'bit_string': '10110110', 'hexdecimal': '0xB6', 'reversed': 0x6D, 'inverted': 0x49, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0xB7: { 'bit_string': '10110111', 'hexdecimal': '0xB7', 'reversed': 0xED, 'inverted': 0x48, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xB8: { 'bit_string': '10111000', 'hexdecimal': '0xB8', 'reversed': 0x1D, 'inverted': 0x47, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0xB9: { 'bit_string': '10111001', 'hexdecimal': '0xB9', 'reversed': 0x9D, 'inverted': 0x46, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0xBA: { 'bit_string': '10111010', 'hexdecimal': '0xBA', 'reversed': 0x5D, 'inverted': 0x45, 'parity': 1, 'ones': 5, '00': 0, '01': 0, '10': 3, '11': 1 },
      0xBB: { 'bit_string': '10111011', 'hexdecimal': '0xBB', 'reversed': 0xDD, 'inverted': 0x44, 'parity': 0, 'ones': 6, '00': 0, '01': 0, '10': 2, '11': 2 },
      0xBC: { 'bit_string': '10111100', 'hexdecimal': '0xBC', 'reversed': 0x3D, 'inverted': 0x43, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xBD: { 'bit_string': '10111101', 'hexdecimal': '0xBD', 'reversed': 0xBD, 'inverted': 0x42, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xBE: { 'bit_string': '10111110', 'hexdecimal': '0xBE', 'reversed': 0x7D, 'inverted': 0x41, 'parity': 0, 'ones': 6, '00': 0, '01': 0, '10': 2, '11': 2 },
      0xBF: { 'bit_string': '10111111', 'hexdecimal': '0xBF', 'reversed': 0xFD, 'inverted': 0x40, 'parity': 1, 'ones': 7, '00': 0, '01': 0, '10': 1, '11': 3 },
      0xC0: { 'bit_string': '11000000', 'hexdecimal': '0xC0', 'reversed': 0x03, 'inverted': 0x3F, 'parity': 0, 'ones': 2, '00': 3, '01': 0, '10': 0, '11': 1 },
      0xC1: { 'bit_string': '11000001', 'hexdecimal': '0xC1', 'reversed': 0x83, 'inverted': 0x3E, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0xC2: { 'bit_string': '11000010', 'hexdecimal': '0xC2', 'reversed': 0x43, 'inverted': 0x3D, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0xC3: { 'bit_string': '11000011', 'hexdecimal': '0xC3', 'reversed': 0xC3, 'inverted': 0x3C, 'parity': 0, 'ones': 4, '00': 2, '01': 0, '10': 0, '11': 2 },
      0xC4: { 'bit_string': '11000100', 'hexdecimal': '0xC4', 'reversed': 0x23, 'inverted': 0x3B, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0xC5: { 'bit_string': '11000101', 'hexdecimal': '0xC5', 'reversed': 0xA3, 'inverted': 0x3A, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0xC6: { 'bit_string': '11000110', 'hexdecimal': '0xC6', 'reversed': 0x63, 'inverted': 0x39, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xC7: { 'bit_string': '11000111', 'hexdecimal': '0xC7', 'reversed': 0xE3, 'inverted': 0x38, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0xC8: { 'bit_string': '11001000', 'hexdecimal': '0xC8', 'reversed': 0x13, 'inverted': 0x37, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0xC9: { 'bit_string': '11001001', 'hexdecimal': '0xC9', 'reversed': 0x93, 'inverted': 0x36, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xCA: { 'bit_string': '11001010', 'hexdecimal': '0xCA', 'reversed': 0x53, 'inverted': 0x35, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0xCB: { 'bit_string': '11001011', 'hexdecimal': '0xCB', 'reversed': 0xD3, 'inverted': 0x34, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xCC: { 'bit_string': '11001100', 'hexdecimal': '0xCC', 'reversed': 0x33, 'inverted': 0x33, 'parity': 0, 'ones': 4, '00': 2, '01': 0, '10': 0, '11': 2 },
      0xCD: { 'bit_string': '11001101', 'hexdecimal': '0xCD', 'reversed': 0xB3, 'inverted': 0x32, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0xCE: { 'bit_string': '11001110', 'hexdecimal': '0xCE', 'reversed': 0x73, 'inverted': 0x31, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xCF: { 'bit_string': '11001111', 'hexdecimal': '0xCF', 'reversed': 0xF3, 'inverted': 0x30, 'parity': 0, 'ones': 6, '00': 1, '01': 0, '10': 0, '11': 3 },
      0xD0: { 'bit_string': '11010000', 'hexdecimal': '0xD0', 'reversed': 0x0B, 'inverted': 0x2F, 'parity': 1, 'ones': 3, '00': 2, '01': 1, '10': 0, '11': 1 },
      0xD1: { 'bit_string': '11010001', 'hexdecimal': '0xD1', 'reversed': 0x8B, 'inverted': 0x2E, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0xD2: { 'bit_string': '11010010', 'hexdecimal': '0xD2', 'reversed': 0x4B, 'inverted': 0x2D, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xD3: { 'bit_string': '11010011', 'hexdecimal': '0xD3', 'reversed': 0xCB, 'inverted': 0x2C, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0xD4: { 'bit_string': '11010100', 'hexdecimal': '0xD4', 'reversed': 0x2B, 'inverted': 0x2B, 'parity': 0, 'ones': 4, '00': 1, '01': 2, '10': 0, '11': 1 },
      0xD5: { 'bit_string': '11010101', 'hexdecimal': '0xD5', 'reversed': 0xAB, 'inverted': 0x2A, 'parity': 1, 'ones': 5, '00': 0, '01': 3, '10': 0, '11': 1 },
      0xD6: { 'bit_string': '11010110', 'hexdecimal': '0xD6', 'reversed': 0x6B, 'inverted': 0x29, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0xD7: { 'bit_string': '11010111', 'hexdecimal': '0xD7', 'reversed': 0xEB, 'inverted': 0x28, 'parity': 0, 'ones': 6, '00': 0, '01': 2, '10': 0, '11': 2 },
      0xD8: { 'bit_string': '11011000', 'hexdecimal': '0xD8', 'reversed': 0x1B, 'inverted': 0x27, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xD9: { 'bit_string': '11011001', 'hexdecimal': '0xD9', 'reversed': 0x9B, 'inverted': 0x26, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0xDA: { 'bit_string': '11011010', 'hexdecimal': '0xDA', 'reversed': 0x5B, 'inverted': 0x25, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0xDB: { 'bit_string': '11011011', 'hexdecimal': '0xDB', 'reversed': 0xDB, 'inverted': 0x24, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xDC: { 'bit_string': '11011100', 'hexdecimal': '0xDC', 'reversed': 0x3B, 'inverted': 0x23, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0xDD: { 'bit_string': '11011101', 'hexdecimal': '0xDD', 'reversed': 0xBB, 'inverted': 0x22, 'parity': 0, 'ones': 6, '00': 0, '01': 2, '10': 0, '11': 2 },
      0xDE: { 'bit_string': '11011110', 'hexdecimal': '0xDE', 'reversed': 0x7B, 'inverted': 0x21, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xDF: { 'bit_string': '11011111', 'hexdecimal': '0xDF', 'reversed': 0xFB, 'inverted': 0x20, 'parity': 1, 'ones': 7, '00': 0, '01': 1, '10': 0, '11': 3 },
      0xE0: { 'bit_string': '11100000', 'hexdecimal': '0xE0', 'reversed': 0x07, 'inverted': 0x1F, 'parity': 1, 'ones': 3, '00': 2, '01': 0, '10': 1, '11': 1 },
      0xE1: { 'bit_string': '11100001', 'hexdecimal': '0xE1', 'reversed': 0x87, 'inverted': 0x1E, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xE2: { 'bit_string': '11100010', 'hexdecimal': '0xE2', 'reversed': 0x47, 'inverted': 0x1D, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0xE3: { 'bit_string': '11100011', 'hexdecimal': '0xE3', 'reversed': 0xC7, 'inverted': 0x1C, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xE4: { 'bit_string': '11100100', 'hexdecimal': '0xE4', 'reversed': 0x27, 'inverted': 0x1B, 'parity': 0, 'ones': 4, '00': 1, '01': 1, '10': 1, '11': 1 },
      0xE5: { 'bit_string': '11100101', 'hexdecimal': '0xE5', 'reversed': 0xA7, 'inverted': 0x1A, 'parity': 1, 'ones': 5, '00': 0, '01': 2, '10': 1, '11': 1 },
      0xE6: { 'bit_string': '11100110', 'hexdecimal': '0xE6', 'reversed': 0x67, 'inverted': 0x19, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0xE7: { 'bit_string': '11100111', 'hexdecimal': '0xE7', 'reversed': 0xE7, 'inverted': 0x18, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xE8: { 'bit_string': '11101000', 'hexdecimal': '0xE8', 'reversed': 0x17, 'inverted': 0x17, 'parity': 0, 'ones': 4, '00': 1, '01': 0, '10': 2, '11': 1 },
      0xE9: { 'bit_string': '11101001', 'hexdecimal': '0xE9', 'reversed': 0x97, 'inverted': 0x16, 'parity': 1, 'ones': 5, '00': 0, '01': 1, '10': 2, '11': 1 },
      0xEA: { 'bit_string': '11101010', 'hexdecimal': '0xEA', 'reversed': 0x57, 'inverted': 0x15, 'parity': 1, 'ones': 5, '00': 0, '01': 0, '10': 3, '11': 1 },
      0xEB: { 'bit_string': '11101011', 'hexdecimal': '0xEB', 'reversed': 0xD7, 'inverted': 0x14, 'parity': 0, 'ones': 6, '00': 0, '01': 0, '10': 2, '11': 2 },
      0xEC: { 'bit_string': '11101100', 'hexdecimal': '0xEC', 'reversed': 0x37, 'inverted': 0x13, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xED: { 'bit_string': '11101101', 'hexdecimal': '0xED', 'reversed': 0xB7, 'inverted': 0x12, 'parity': 0, 'ones': 6, '00': 0, '01': 2, '10': 0, '11': 2 },
      0xEE: { 'bit_string': '11101110', 'hexdecimal': '0xEE', 'reversed': 0x77, 'inverted': 0x11, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xEF: { 'bit_string': '11101111', 'hexdecimal': '0xEF', 'reversed': 0xF7, 'inverted': 0x10, 'parity': 1, 'ones': 7, '00': 0, '01': 0, '10': 1, '11': 3 },
      0xF0: { 'bit_string': '11110000', 'hexdecimal': '0xF0', 'reversed': 0x0F, 'inverted': 0x0F, 'parity': 0, 'ones': 4, '00': 2, '01': 0, '10': 0, '11': 2 },
      0xF1: { 'bit_string': '11110001', 'hexdecimal': '0xF1', 'reversed': 0x8F, 'inverted': 0x0E, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0xF2: { 'bit_string': '11110010', 'hexdecimal': '0xF2', 'reversed': 0x4F, 'inverted': 0x0D, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xF3: { 'bit_string': '11110011', 'hexdecimal': '0xF3', 'reversed': 0xCF, 'inverted': 0x0C, 'parity': 0, 'ones': 6, '00': 1, '01': 0, '10': 0, '11': 3 },
      0xF4: { 'bit_string': '11110100', 'hexdecimal': '0xF4', 'reversed': 0x2F, 'inverted': 0x0B, 'parity': 1, 'ones': 5, '00': 1, '01': 1, '10': 0, '11': 2 },
      0xF5: { 'bit_string': '11110101', 'hexdecimal': '0xF5', 'reversed': 0xAF, 'inverted': 0x0A, 'parity': 0, 'ones': 6, '00': 0, '01': 2, '10': 0, '11': 2 },
      0xF6: { 'bit_string': '11110110', 'hexdecimal': '0xF6', 'reversed': 0x6F, 'inverted': 0x09, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xF7: { 'bit_string': '11110111', 'hexdecimal': '0xF7', 'reversed': 0xEF, 'inverted': 0x08, 'parity': 1, 'ones': 7, '00': 0, '01': 1, '10': 0, '11': 3 },
      0xF8: { 'bit_string': '11111000', 'hexdecimal': '0xF8', 'reversed': 0x1F, 'inverted': 0x07, 'parity': 1, 'ones': 5, '00': 1, '01': 0, '10': 1, '11': 2 },
      0xF9: { 'bit_string': '11111001', 'hexdecimal': '0xF9', 'reversed': 0x9F, 'inverted': 0x06, 'parity': 0, 'ones': 6, '00': 0, '01': 1, '10': 1, '11': 2 },
      0xFA: { 'bit_string': '11111010', 'hexdecimal': '0xFA', 'reversed': 0x5F, 'inverted': 0x05, 'parity': 0, 'ones': 6, '00': 0, '01': 0, '10': 2, '11': 2 },
      0xFB: { 'bit_string': '11111011', 'hexdecimal': '0xFB', 'reversed': 0xDF, 'inverted': 0x04, 'parity': 1, 'ones': 7, '00': 0, '01': 0, '10': 1, '11': 3 },
      0xFC: { 'bit_string': '11111100', 'hexdecimal': '0xFC', 'reversed': 0x3F, 'inverted': 0x03, 'parity': 0, 'ones': 6, '00': 1, '01': 0, '10': 0, '11': 3 },
      0xFD: { 'bit_string': '11111101', 'hexdecimal': '0xFD', 'reversed': 0xBF, 'inverted': 0x02, 'parity': 1, 'ones': 7, '00': 0, '01': 1, '10': 0, '11': 3 },
      0xFE: { 'bit_string': '11111110', 'hexdecimal': '0xFE', 'reversed': 0x7F, 'inverted': 0x01, 'parity': 1, 'ones': 7, '00': 0, '01': 0, '10': 1, '11': 3 },
      0xFF: { 'bit_string': '11111111', 'hexdecimal': '0xFF', 'reversed': 0xFF, 'inverted': 0x00, 'parity': 0, 'ones': 8, '00': 0, '01': 0, '10': 0, '11': 4 }
    }

    def __init__(self, initalizer):
        if isinstance(initalizer, bytearray):
            self.data = initalizer
        elif isinstance(initalizer, bytes):
            self.data = bytearray(initalizer)
        else:
            raise TypeError("Input data must be either of class bytearray or class bytes.")

    def random(self):
        for row in range(len(self.data)):
            self.data[row] = random.randint(0, 255)

    def flip_vertically(self, debug=0):
        # self.data = ( byte_transforms[self.data[_],'reversed'] for _ in range(8))
        rotated = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        for i in range(len(self.data)):
            rotated.data[i] = self.data[ ( 7 - i ) ]
        self.data = rotated.data

    def flip_horizontally(self, debug=0):
        # self.data = self.data[::-1]
        for i in range(len(self.data)):
            self.data[i] = ByteTransformer.byte_transforms[self.data[i]]['reversed']

    def increment_bytes(self):
        for i in range(len(self.data)):
            self.data[i] = (self.data[i] + 1) % 256  # Handle overflow

    def decrement_bytes(self):
        for i in range(len(self.data)):
            self.data[i] = (self.data[i] - 1) % 256  # Handle underflow

    def invert(self):
        for i in range(len(self.data)):
            # print(i)
            # print(self.data[i])
            # print(type(self.data[i]))
            # self.data[i] = ByteTransformer.byte_transforms[self.data[i],'inverted']
            self.data[i] = ByteTransformer.byte_transforms[self.data[i]]['inverted']

    def parameters (self,debug=0):
        parameters = { 'ones' : 0, '00' : 0, '01' : 0, '10' : 0, '11' : 0, 'h_parity' : 0, 'v_parity' : 0 }
        for i in range(len(self.data)):
            row = ( 7 - i )
            byte = self.data[row]
            if (debug):
                print(f"{byte:3d}", ByteTransformer.byte_transforms[byte]['bit_string'], ByteTransformer.byte_transforms[byte]['parity'], ByteTransformer.byte_transforms[byte]['ones'])
            parameters['v_parity'] |= ByteTransformer.byte_transforms[byte]['parity']
            if row > 0:
                parameters['v_parity'] <<= 1
            parameters['ones']     += ByteTransformer.byte_transforms[byte]['ones']
            parameters['00']       += ByteTransformer.byte_transforms[byte]['00']
            parameters['01']       += ByteTransformer.byte_transforms[byte]['01']
            parameters['10']       += ByteTransformer.byte_transforms[byte]['10']
            parameters['11']       += ByteTransformer.byte_transforms[byte]['11']
            parameters['h_parity'] ^= byte
        if (debug):
            print('   ', ByteTransformer.byte_transforms[parameters['h_parity']]['bit_string'], ' horizontal parity')
            print('   ', ByteTransformer.byte_transforms[parameters['v_parity']]['bit_string'], ' vertical   parity')
            print('Total one bits: ', parameters['ones'] )
            print('Total 00  bits: ', parameters['00'] )
            print('Total 01  bits: ', parameters['01'] )
            print('Total 10  bits: ', parameters['10'] )
            print('Total 11  bits: ', parameters['11'] )
        return parameters

# R
# O
# W         COLUMN
#      7 6 5 4 3 2 1 0
#      - - - - - - - -                       Rotation 90 degrees clockwise
# 0 |  A B C D E F G H    0 0 0 a 0 0 0 A    Row 0 -> Column 0  Column 0 -> Row 7
# 1 |  0 0 0 0 0 0 0 0    0 0 0 b 0 0 0 B    Row 1 -> Column 1  Column 0 -> Row 7
# 2 |  0 0 0 0 0 0 0 0    0 0 0 c 0 0 0 C    Row 2 -> Column 2  Column 0 -> Row 7
# 3 |  0 0 0 0 0 0 0 0    0 0 0 d 0 0 0 D    Row 3 -> Column 3  Column 0 -> Row 7
# 4 |  a b c d e f g h    0 0 0 e 0 0 0 E    Row 4 -> Column 4  Column 0 -> Row 7
# 5 |  0 0 0 0 0 0 0 0    0 0 0 f 0 0 0 F    Row 5 -> Column 5  Column 0 -> Row 7
# 6 |  0 0 0 0 0 0 0 0    0 0 0 g 0 0 0 G    Row 6 -> Column 6  Column 0 -> Row 7
# 7 |  0 0 0 0 0 0 0 0    0 0 0 h 0 0 0 H    Row 7 -> Column 7  Column 0 -> Row 7

    def rotate_90_CW(self, debug=0):
        """Rotates the bits in a bytearray of length 8 by 90 degrees clockwise."""
        rotated = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            self.print_as_bit_array("Object before rotation:")
        for row in range(8):    # loop over rows from top to bottom
            set_mask = 1 << row
            for col in range(8):  # loop over cols from right to left
                # bit at input_bytearray[row,col] will be isolated as a single-one binary number,
                # ie 00010000 for col = 4
                bit = self.data[row] & (128 >> col)
                if (bit):
                    rotated.data[col] |= set_mask
        if (debug):
            self.print_as_bit_array("Rotated CW:")
        self.data = rotated.data

    def rotate_90_CCW(self, debug=0):
        """Rotates the bits in a bytearray of length 8 by 90 degrees counter-clockwise."""
        rotated = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            self.print_as_bit_array("Object before rotation:")
        for row in range(8):    # loop over rows from top to bottom
            set_mask = 1 << ( 7 - row )
            for col in range(8):  # loop over cols from right to left
                # bit at input_bytearray[row,col] will be isolated as a single-one binary number,
                # ie 00010000 for col = 4
                bit = self.data[row] & (1 << col)
                if (bit):
                    rotated.data[col] |= set_mask
        if (debug):
            self.print_as_bit_array("Rotated CCW:")
        self.data = rotated.data

    def rotate_180(self, debug = 0):
        """Rotates the bits in a bytearray of length 8 by 180 degrees."""
        
        rotated = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            print(f"self before rotation {self}")
            self.print_as_bit_array("Object before rotation:")
        for i in range(len(self.data)):
            destination = ( 7 - i )
            rotated.data[destination] = ByteTransformer.byte_transforms[self.data[i]]['reversed']
        if (debug):
            rotated.print_as_bit_array("Rotated 180:")
            print(f"self after rotation {self}")
        self.data = rotated.data

    def duplicate(self, other):
        for i in range(len(self.data)):
            self.data[i] = other.data[i]

    def to_hex_string(self):
        return self.data.hex()

    def output_file(self, output_source="-", debug=0):
        encoding = "utf-8"  # Replace with the appropriate encoding
        if (debug):
          print(f"write_to has started with output_source specified as {output_source}.")
        if output_source == '-':
          output_file = sys.stdout.buffer  # Use binary mode for standard output
        elif isinstance(output_source, str):
          try:
            output_file = open(output_source, 'wb')  # Open file in binary mode
          except FileNotFoundError:
            raise ValueError(f"Invalid output source: File '{output_source}' not found")
        elif isinstance(output_source, (io.TextIOBase, io.BufferedIOBase, io.RawIOBase)):
          output_file = output_source
        else:
          raise ValueError(f"Invalid output source: {output_source}")
        if (debug):
          print(f"write_to has ended with output_source specified as {input_source}.")
        return output_file

    def write_to(self, output_file, debug=0):
        debug = 0
        encoding = "utf-8"  # Replace with the appropriate encoding
        if (debug):
          print(f"write_to has started with output_source specified as {output_source}.")
        try:
          output_file.write(self.data)
        except IOError as e:
          print("Error writing file:", e)
        if (debug):
          print(f"write_to has ended with output_source specified as {input_source}.")

    def read_from(self, input_source="-", debug=0):
        """Reads 8 bytes at a time from a file or standard input.
        Args:
          input_source: The input source, either a filename as a string or '-' for standard input or a filehandle
        Yields:
          Chunks of 8 bytes as bytearrays.
        Raises:
          ValueError: If the input source is not a valid file or '-'.
        """
        encoding = "utf-8"  # Replace with the appropriate encoding
        if (debug):
          print(f"read_from has started with input_source specified as {input_source}.")
        if input_source == '-':
          input_file = sys.stdin.buffer  # Use binary mode for standard input
        elif isinstance(input_source, str):
          try:
            input_file = open(input_source, 'rb')  # Open file in binary mode
          except FileNotFoundError:
            raise ValueError(f"Invalid input source: File '{input_source}' not found")
        elif isinstance(input_source, (io.TextIOBase, io.BufferedIOBase, io.RawIOBase)):
          input_file = input_source
        else:
          raise ValueError(f"Invalid input source: {input_source}")
        try:
          while True:
            chunk = input_file.read(8)
            # print(f"chunk read {chunk}.")
            if not chunk:
              break
            # yield 1
            if isinstance(chunk, (bytearray, bytes)):
                self.data = bytearray(chunk)  # No need for encoding
            else:
                self.data = bytearray(chunk, encoding=encoding)
            yield self.data
        finally:
          if input_source != '-':
            input_file.close()
        if (debug):
          print(f"read_from has ended with input_file specified as {input_file}.")

    def print_as_bytes(self, label=""):
        """ Output as an list of 8 bytes."""
        if (label):
            print(label)
        for byte in self.data:
            print(f"{byte:02x}")

    def print_as_bit_array(self, label=""):
        # print(self)
        """ Output as an 8x8 grid of bits."""
        if (label):
            print(label)
        for byte in self.data:
            print(f"{byte:08b}")

    def print_comparison(self, other):
        """ Outputs two bytearrays of length 8 into two side-by-side 8x8 grids of bits."""
        for i in range(len(self.data)):
            left  = self.data[i]
            right = other.data[i]
            # print(f"{left:08b}  {left:c} : {right:08b}  {right:c}")
            print(f"{left:08b}\t{right:08b}")

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

    def barber_pole(self, debug=0):
        # swap adjacent even and odd columns
        barber_poled = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            self.print_as_bit_array(f"Object before barber_poling:")
        for row in range(len(self.data)):
            barber_poled.data[row] = ( self.data[row] & 0xAA ) >> 1 | \
                                     ( self.data[row] & 0x55 ) << 1
        if (debug):
            self.print_as_bit_array(f"Barber_poled:")
        self.data = barber_poled.data

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

    def shift_horizontally(self, param, debug=0):
        param %= 8
        # shifts the block of bits, shifting each column left param % 8
        shifted = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            self.print_as_bit_array(f"Object before horizontal shifting by {param}:")
        for row in range(len(self.data)):
            shifted.data[row] = ( self.data[row] & ByteTransformer.shift_mask_left[param]  ) >> ( 8 - param ) | \
                                ( self.data[row] & ByteTransformer.shift_mask_right[param] ) << param
        if (debug):
            self.print_as_bit_array(f"Shifted horizontally by {param}:")
        self.data = shifted.data

    def shift_vertically(self, param, debug=0):
        param %= 8
        # shifts the block of bits, shifting each row down param % 8
        shifted = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            self.print_as_bit_array(f"Object before vertically shifting by {param}:")
        for row in range(len(self.data)):
            shifted.data[ ( row + param ) % len(self.data) ] = self.data[row]
        if (debug):
            self.print_as_bit_array(f"Sheered vertically by {param}:")
        self.data = shifted.data

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

    def sheer_horizontally(self, param, debug=0):
        """sheers the block of bits, rotating each row of bits by a number of bits
        to the left.  The number of bits shifted starts at param (which must be
        between 1 and 7 inclusive) and increases by param for each row, modulo 8.
        The last row is always unchanged, see Notes.txt"""
        sheered = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            self.print_as_bit_array("Object before horizontal sheering:")
        for row in range(len(self.data)):
            shift = ( param * row ) % 8
            sheered.data[row] = ( self.data[row] & ByteTransformer.shift_mask_left[shift]  ) >> ( 8 - shift ) | \
                                ( self.data[row] & ByteTransformer.shift_mask_right[shift] ) << shift
            if (debug>1):
                print(f"  row is {row} & shift is {shift}")
                left = self.data[row] & ByteTransformer.shift_mask_left[shift]
                print(f"  left side is {left:08b} and will be shifted right by 7 - {shift}")
                right = self.data[row] & ByteTransformer.shift_mask_right[shift]
                print(f"  right side is {right:08b} and will be shifted left by {shift}")
        self.data = sheered.data
        if (debug):
            self.print_as_bit_array(f"Sheered horizontally by {param}:")

    def sheer_vertically(self, param, debug=0):
        """sheers the block of bits, rotating each column of bits by a number of bits
        to the down.  The number of bits shifted starts at param (which must be
        between 1 and 7 inclusive) and increases by param for each col, modulo 8.
        The last row is always unchanged, see Notes.txt
        unlike horizontal sheer, we will locate each bit seperately and place it
        into the sheered array.  """
        sheered = ByteTransformer(bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00'))
        if (debug):
            self.print_as_bit_array("Object before vertically sheering:")
        for col in range(8):
            sensor = ByteTransformer.bit_sensor[col]
            for row in range(len(self.data)):
                if (sensor & self.data[row]): # detect bit at this row,col
                    shift = ( param * col + row ) % len(self.data)  # if bit detected, find new col for vertically-shifted bit
                    sheered.data[shift] |= sensor
        self.data = sheered.data
        if (debug):
            self.print_as_bit_array(f"Sheered vertically by {param}:")

    def not_a_method(self):
        print("Not yet implemented")

# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
#  Transforms
#   - rotate_90_CCW
#   - rotate_90_CW
#   - rotate_180
#   - invert
#   - horizontal_sheer
#   - vertical_sheer
#   + flip_horizontal
#   + flip_vertical
#   + increment_bytes
#   + decrement_bytes
#  Utilities
#   - compare
#   + print_as_bytes
#   + print_as_bit_array
#   + print_comparison
#   + read_from
#   + duplicate
#   + parameters
#   + random
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

