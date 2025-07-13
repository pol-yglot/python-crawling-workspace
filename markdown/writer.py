# markdown/writer.py
from datetime import datetime
import os

def generate_markdown(data, output_dir="output"):
    from keywords import extract_common_keywords

    now = datetime.now()
    today_str = now.strftime("%Y-%m-%d")
    filename_time = now.strftime("%Y%m%d_%H%M")
    blog_title = f"[뉴스 요약] {today_str} – 금융·보안 동향 정리"

    grouped = {}
    for item in data:
        src = item.get("출처", "기타")
        grouped.setdefault(src, []).append(item)

    md_lines = [f"# {today_str} 뉴스 요약", "", "아래는 각 기관에서 발표한 주요 뉴스입니다.", ""]

    for org, items in grouped.items():
        md_lines.append(f"## {org}")
        for item in items:
            md_lines.append(f"- [{item['제목']}]({item['링크']})")
        md_lines.append("")

    # 주요 키워드 추가
    titles = [item["제목"] for item in data]
    keywords = extract_common_keywords(titles)
    if keywords:
        md_lines.append("## 🔍 주요 키워드")
        md_lines.append("뉴스 제목에서 추출된 핵심 키워드입니다:")
        for word, count in keywords:
            md_lines.append(f"- **{word}** ({count}회)")
        md_lines.append("")

    markdown_output = "\n".join(md_lines)

    folder_path = os.path.join(output_dir, today_str)
    os.makedirs(folder_path, exist_ok=True)

    filename = os.path.join(folder_path, f"뉴스요약_{filename_time}.md")
    with open(filename, "w", encoding="utf-8") as f:
        f.write(f"# {blog_title}\n\n")
        f.write(markdown_output)

    print("\n" + "=" * 80)
    print("📌 티스토리에 올릴 블로그 글")
    print("=" * 80)
    print(f"\n제목: {blog_title}\n")
    print(markdown_output)
    print(f"\n✅ 마크다운 파일 저장 완료: {filename}")
