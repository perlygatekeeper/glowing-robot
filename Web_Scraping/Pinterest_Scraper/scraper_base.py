import requests
from bs4 import BeautifulSoup
from typing import Optional, Callable
import logging

import time
import random

def polite_sleep(self, base=1.0, jitter=0.5):
    time.sleep(base + random.uniform(0, jitter))

class WebScraper:
    """
    Base class for building authenticated or non-authenticated web scrapers.
    """

    def __init__(
        self,
        base_url: str,
        headers: Optional[dict] = None,
        timeout: int = 10,
        logger: Optional[logging.Logger] = None
    ):
        self.base_url = base_url
        self.timeout = timeout

        self.session = requests.Session()
        self.session.headers.update(
            headers or {
                "User-Agent": (
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/120.0 Safari/537.36"
                )
            }
        )

        self.logger = logger or logging.getLogger(self.__class__.__name__)

    def login(
        self,
        login_url: str,
        username: str,
        password: str,
        username_field: str = "username",
        password_field: str = "password",
        extra_payload: Optional[dict] = None,
        success_check: Optional[Callable[[requests.Response], bool]] = None,
    ) -> bool:
        """
        Perform form-based login with robust verification.
        """

        payload = {
            username_field: username,
            password_field: password
        }

        if extra_payload:
            payload.update(extra_payload)

        try:
            response = self.session.post(
                login_url,
                data=payload,
                timeout=self.timeout
            )
            response.raise_for_status()

            # Custom success check (preferred)
            if success_check:
                if not success_check(response):
                    self.logger.warning("Custom login check failed.")
                    return False
                return True

            # Default heuristic checks
            soup = BeautifulSoup(response.text, "html.parser")

            if soup.find("input", {"type": "password"}):
                self.logger.warning("Password field still present — login likely failed.")
                return False

            if not self.session.cookies:
                self.logger.warning("No cookies set — login likely failed.")
                return False

            return True

        except requests.exceptions.Timeout:
            self.logger.error("Login request timed out.")
        except requests.exceptions.HTTPError as e:
            self.logger.error(f"Login HTTP error [{e.response.status_code}]")
        except Exception as e:
            self.logger.exception(f"Unexpected login error: {e}")

        return False

    def fetch_page(self, url: str) -> Optional[str]:
        try:
            response = self.session.get(url, timeout=self.timeout)
            response.raise_for_status()
            return response.text
        except Exception as e:
            self.logger.error(f"Failed to fetch {url}: {e}")
            return None

    @staticmethod
    def parse_html(html: str) -> BeautifulSoup:
        return BeautifulSoup(html, "html.parser")

    def scrape(self):
        raise NotImplementedError

