import re
from webscraper import WebScraper

class ExampleScraper(WebScraper):
    def scrape(self):
        seen = self.load_checkpoint()

        start_url = self.base_url + self.config["scraping"]["start_path"]
        next_sel = self.config["scraping"]["next_page_selector"]

        sections_pattern = re.compile(r"(\d+)\s+sections", re.IGNORECASE)

        for soup in self.fetch_all_pages(start_url, next_sel):
            items = soup.find_all("div", role="listitem")

            for item in items:
                a = item.find("a", href=True)
                if not a:
                    continue

                link = a["href"]
                if link in seen:
                    continue
                seen.add(link)

                text = a.get_text(strip=True)
                match = sections_pattern.search(text)
                if not match:
                    continue

                self.data.append({
                    "url": link,
                    "title": text.partition(",")[0],
                    "sections": int(match.group(1))
                })

            self.save_checkpoint(seen)
            self.polite_sleep()
