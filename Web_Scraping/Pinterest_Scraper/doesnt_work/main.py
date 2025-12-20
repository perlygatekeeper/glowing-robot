from example_scraper import ExampleScraper

if __name__ == "__main__":
    scraper = ExampleScraper("config.yaml")
    scraper.login()

    scraper.run() \
        .filter(lambda x: x["sections"] >= 20) \
        .transform(lambda x: {
            **x,
            "title": x["title"].title()
        })

    for item in scraper.data:
        print(item)
