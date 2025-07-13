# crawler/itchosun.py
import requests
from bs4 import BeautifulSoup

# request+BeautifulSoup 방식으로 크롤링 : 정적 페이지에서 데이터 추출하기 위해
def crawl_it_chosun_fintech():
    url = "https://it.chosun.com/news/articleList.html?sc_sub_section_code=S2N28&view_type=sm"
    headers = {"User-Agent": "Mozilla/5.0"}

    res = requests.get(url, headers=headers)
    if res.status_code != 200:
        print("요청 실패:", res.status_code)
        return []

    soup = BeautifulSoup(res.content.decode('utf-8', errors='replace'), 'html.parser')
    news_items = []

    article_tags = soup.select("li.item h2.titles a")
    for tag in article_tags[:10]:
        title = tag.get_text(strip=True)
        link = tag.get("href", "")
        if not link.startswith("http"):
            link = "https://it.chosun.com" + link
        news_items.append({
            "출처": "IT조선",
            "제목": title,
            "링크": link
        })

    return news_items
