import os
from datetime import datetime
from keywords import extract_common_keywords
from typing import List, Tuple, Dict

def generate_markdown(data: List[Dict[str, str]]) -> None:
    today = datetime.today().strftime("%Y-%m-%d")
    filename_time = datetime.today().strftime("%Y%m%d_%H%M")

    blog_title = f"[뉴스 요약] {today} – 금융·보안 동향 정리"

    # 출처별로 그룹핑
    grouped = {}
    for item in data:
        src = item.get("출처", "기타")
        grouped.setdefault(src, []).append(item)

    md_lines = [
        f"# {today} 뉴스 요약",
        "",
        "아래는 각 기관에서 발표한 주요 뉴스입니다.",
        ""
    ]

    # 공통 키워드 추출 (Tuple[str, int] 형식) - 비어있으면 스킵
    keywords: List[Tuple[str, int]] = []
    try:
        if data and len(data) > 0:
            keywords = extract_common_keywords([item["제목"] for item in data])
    except Exception as e:
        print(f"[키워드 추출] 경고: {e} - 키워드 추출을 건너뜁니다.")
    
    if keywords:
        keyword_str = ", ".join([kw[0] for kw in keywords])
        md_lines.insert(4, "##주요 키워드: " + keyword_str)
        md_lines.insert(5, "")

    for org, items in grouped.items():
        md_lines.append(f"## {org}")
        for item in items:
            md_lines.append(f"- [{item['제목']}]({item['링크']})")
        md_lines.append("")  # 기관별 구분용 공백

    markdown_output = "\n".join(md_lines)

    print("\n" + "=" * 80)
    print("티스토리에 올린 블로그 글")
    print("=" * 80)
    print(f"\n제목: {blog_title}\n")
    print(markdown_output)

    # 절대경로 출력 디렉토리 지정
    base_dir = os.path.abspath(os.path.dirname(__file__))
    output_dir = os.path.join(base_dir, "output")
    folder_path = os.path.join(output_dir, today)
    os.makedirs(folder_path, exist_ok=True)

    filename = os.path.join(folder_path, f"뉴스요약_{filename_time}.md")
    with open(filename, "w", encoding="utf-8") as f:
        f.write(f"# {blog_title}\n\n")
        f.write(markdown_output)

    print(f"\n마크다운 파일 저장 완료: {filename}")
