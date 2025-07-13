# crawler/kisa.py
import time
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

def crawl_kisa_selenium():
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1920x1080")

    service = Service(r"내경로\\chromedriver.exe")
    driver = webdriver.Chrome(service=service, options=options)

    try:
        driver.get("https://www.kisa.or.kr/20207")
        time.sleep(3)
        soup = BeautifulSoup(driver.page_source, "html.parser")
        rows = soup.select("table.tbl_board.notice tbody tr")

        data = []
        for row in rows[:5]:
            link_elem = row.select_one("td.sbj a")
            if link_elem:
                title = link_elem.text.strip()
                href = link_elem.get("href", "")
                link = "https://www.kisa.or.kr" + href
                data.append({"출처": "KISA", "제목": title, "링크": link})
        return data
    finally:
        driver.quit()