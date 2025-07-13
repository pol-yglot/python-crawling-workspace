from konlpy.tag import Okt
from collections import Counter

def extract_common_keywords(titles, top_n=10):
    okt = Okt()
    words = []

    for title in titles:
        nouns = okt.nouns(title)
        words.extend(nouns)

    # 불용어 제거
    stopwords = set(['것', '수', '등', '및', '이', '를', '에', '로', '은', '는', '의', '도', '가', '과'])
    filtered = [w for w in words if w not in stopwords and len(w) > 1]

    counter = Counter(filtered)
    return counter.most_common(top_n)
