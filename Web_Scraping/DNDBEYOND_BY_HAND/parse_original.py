import os
from bs4 import BeautifulSoup
import fnmatch

# Step 1: Define the directory containing the HTML files
HTML_FILES_DIRECTORY = "./"  # Replace with the actual directory path

def parse_html_files(directory):
    """
    Parse all HTML files in the specified directory and extract content within <div> tags.
    """
    # Step 2: Iterate through all files in the directory
    for filename in sorted(os.listdir(directory)):
        # if filename.fnmatch("?.html"):  # Process only .html files
        if fnmatch.fnmatch(filename, "A.html"):
            # print(f"{filename}")
            
            file_path = os.path.join(directory, filename)
            print(f"Parsing file: {filename}")
            
            try:
                # Step 3: Open and read the HTML file
                with open(file_path, "r", encoding="utf-8") as file:
                    html_content = file.read()
                
                # Step 4: Parse the HTML content using BeautifulSoup
                soup = BeautifulSoup(html_content, "html.parser")
                
                # Step 5: Find all <div> tags and extract their content
                div_tags = soup.find_all("div", class_ = "stat-block")
                if div_tags:
                    for i, div in enumerate(div_tags, start=1):
                        print(f" stats-block  div {i} content:")
                        print(f"  {div.get_text(strip=True)}")  # Extract text content of the <div>
                        # print(f"  {div.get_text(strip=False)}")  # Extract text content of the <div>
                        # print(f"  {div}")  # Extract text content of the <div>
                        print("-" * 10)
                        try:
                            h4 = div.find("h4")  # Finds the first <h4> tag inside the stat-block div
                            print(f"Found <h4>: {h4.text}")
                        except Exception as e:
                            print("No <h4> tag found.")
                        print("-" * 10)
                        try:
                            ps = div.find_all("p")  # Finds the <p> tags inside the stats-block div
                            for p in ps:
                                print(f"Found <p>: {p.text}")
                        except Exception as e:
                           print(f"  Error finding the <p> tags from {dir}: {e}")
                        print("-" * 40)
                else:
                    print("  No <div> tags found in this file.")
            
            except Exception as e:
                print(f"  Error processing file {filename}: {e}")
            break
        
        else:
            print(f"Skipping non-matching file: {filename}")

# Step 6: Run the script
if __name__ == "__main__":
    parse_html_files(HTML_FILES_DIRECTORY)
