# crawler/sedaily.py
import requests
from bs4 import BeautifulSoup

# request+BeautifulSoup 방식으로 크롤링 : 정적 페이지에서 데이터 추출하기 위해
def crawl_sedaily_economy():
    url = "https://www.sedaily.com/v/NewsMain/GC"
    headers = {"User-Agent": "Mozilla/5.0"}
    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        print("요청 실패:", response.status_code)
        return []

    soup = BeautifulSoup(response.content.decode('utf-8', errors='replace'), 'html.parser')
    news_items = []

    main_articles = soup.select("div.sub_news > div")
    sub_articles = soup.select("ul.sub_news_list > li")

    def parse_article(tag):
        title_tag = tag.select_one("div.article_tit a")
        if not title_tag:
            return None
        title = title_tag.get_text(strip=True)
        link = title_tag['href']
        if not link.startswith("http"):
            link = "https://www.sedaily.com" + link
        return {"출처": "서울경제", "제목": title, "링크": link}

    for tag in main_articles + sub_articles:
        item = parse_article(tag)
        if item:
            news_items.append(item)

    return news_items[:10]
