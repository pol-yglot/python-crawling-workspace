# main.py
from crawler import crawl_kisa_selenium, crawl_sedaily_economy, crawl_it_chosun_fintech
from markdown import generate_markdown
from keywords import extract_common_keywords

def safe_crawl(func, name):
    try:
        return func()
    except Exception as e:
        print(f"❌ [{name}] 크롤링 실패: {e}")
        return []

def main():
    print("🔍 뉴스 크롤링 시작...")

    kisa = safe_crawl(crawl_kisa_selenium, "KISA")
    sedaily = safe_crawl(crawl_sedaily_economy, "서울경제")
    itchosun = safe_crawl(crawl_it_chosun_fintech, "IT조선")

    all_data = kisa + sedaily + itchosun

    if not all_data:
        print("❌ 크롤링된 뉴스가 없습니다. 종료합니다.")
        return

    generate_markdown(all_data)

    # titles = [item["제목"] for item in all_data]
    # keywords = extract_common_keywords(titles)

    # print("\n📌 주요 키워드:")
    # for word, count in keywords:
    #     print(f"- {word}: {count}")

if __name__ == "__main__":
    main()
