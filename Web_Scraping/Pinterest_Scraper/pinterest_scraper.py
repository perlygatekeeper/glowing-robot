#!/usr/bin/env python3
import re
import logging
from scraper_base import WebScraper
from settings import load_config, get_env_or_config

import argparse
from storage import save_csv, save_json, save_sqlite

logging.basicConfig(level=logging.INFO)

config = load_config("config_pinterest.yaml")

USERNAME = get_env_or_config(
    "SCRAPER_USERNAME",
    config,
    "login", "username"
)

PASSWORD = get_env_or_config(
    "SCRAPER_PASSWORD",
    config,
    "login", "password"
)

LOGIN_URL = config["login"]["url"]
BASE_URL = config["base_url"]

parser = argparse.ArgumentParser()
parser.add_argument("--csv")
parser.add_argument("--json")
parser.add_argument("--sqlite")
args = parser.parse_args()

class ExampleScraper(WebScraper):

    def scrape(self):
        html = self.fetch_page(f"{BASE_URL}/perlygatekeeper")
        if not html:
            return None

        soup = self.parse_html(html)
        list_items = soup.find_all("div", attrs={"role": "listitem"})
        sections_pattern = re.compile(r"(\d+)\s+sections", re.IGNORECASE)
        for list_item in list_items:
            a_tag = list_item.find("a")
            if a_tag:
                link = a_tag.get("href")  # get href attribute
                text = a_tag.text.strip()
                print(f"{link:<80} {text:<80}")
                sections_match = sections_pattern.search(text)
                # if sections_match:
                #     num_sections = int(sections_match.group(1))  # capture the digits
                #     print(f"Which has {num_sections} sections...")
                # else:
                #     print("no sections detected here")
                    
        return {
            "title": soup.title.string.strip() if soup.title else None
        }


def login_success_check(response):
    # Example: ensure dashboard redirect
    return "/" in response.url


if __name__ == "__main__":
    scraper = ExampleScraper(BASE_URL)

    if not scraper.login(
        login_url=LOGIN_URL,
        username=USERNAME,
        password=PASSWORD,
        username_field=config["login"]["username_field"],
        password_field=config["login"]["password_field"],
        success_check=login_success_check
    ):
        raise SystemExit("Login failed")

    data = scraper.scrape()
    print(data)

