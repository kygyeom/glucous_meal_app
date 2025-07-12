컨셉 디자인 figma (https://www.figma.com/design/26EEnOW4y2Eqd6I7xd2FIx/GLucoUS-APP?node-id=206-6907&t=Oqv17ITUCPH2n2Pi-1)
---

# 🥗 GlucoUS Meal Recommendation App

**개인 맞춤형 혈당 식단 추천 앱**
Flutter + FastAPI 기반으로, 사용자 정보와 라이프스타일을 바탕으로 건강한 식단을 추천합니다.

---

## 📦 폴더 구조

```plaintext
glucous_meal_app/
├── lib/
│   ├── screens/              # 각 페이지 UI
│   │   ├── user_info_screen.dart
│   │   ├── lifestyle_screen.dart
│   │   ├── summary_screen.dart
│   │   ├── meal_recommendation_screen.dart
│   │   └── meal_detail_screen.dart
│   ├── models/
│   │   └── models.dart       # UserProfile 및 Recommendation 데이터 모델
│   ├── services/
│   │   └── api_service.dart  # FastAPI 서버와의 통신 로직
│   └── main.dart
│
├── main.py # 서버 코드 
└── README.md
```

---

물론입니다! 아래는 **GlucoUS 프로젝트 실행을 위한 핵심 요약 `README.md` 설치 가이드**입니다:

---

# 🥗 GlucoUS – 개인 맞춤형 혈당 식단 추천 앱

Flutter + FastAPI 기반 식단 추천 시스템

---

## ✅ 설치 요약

### 📦 프로젝트 클론

```bash
git clone https://github.com/your-username/glucous-meal-app.git
cd glucous_meal_app
```

---

## ⚙️ Flutter 설치 (Linux 기준)

```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor  # 설치 상태 점검
```

[공식 문서 보기](https://docs.flutter.dev/get-started/install)

---

## 🚀 실행 방법

### 1️⃣ FastAPI 서버 실행

```bash
cd server/
pip install fastapi uvicorn
uvicorn main:app --reload
```

* 주소 확인: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

---

### 2️⃣ Flutter 앱 실행

```bash
cd ..
flutter pub get
flutter run -d linux   # 또는 chrome / android 등
```

> `lib/services/api_service.dart` 내 서버 주소를 `http://127.0.0.1:8000`로 설정

※ 모바일 기기에서 테스트 시 `127.0.0.1` → PC IP 주소로 변경 필요

---


---

이제 복사해서 바로 `README.md`로 저장하시면 됩니다. 원하시면 배포/CI/CD나 Firebase 연동 부분도 추가해드릴게요.


#### 🧩 서버 주소 확인

`lib/services/api_service.dart`에서 주소가 `http://127.0.0.1:8000/recommend`로 설정되어 있는지 확인하세요.

📱 모바일 기기에서 테스트하려면, `127.0.0.1` 대신 같은 네트워크의 PC IP를 사용해야 합니다.

---

## 🧪 테스트 시나리오

1. 사용자 정보 입력
2. 식습관 & 제약 조건 입력
3. 개인정보 동의 후 서버 전송
4. 추천 식단 표시
5. 식단 클릭 시 상세정보 확인

---

## 🧠 향후 개선 아이디어

* 실제 혈당 반응 기반 추천 알고리즘 연동
* Firebase 또는 Supabase 연동
* 로그인/회원가입 기능 추가
* 식단 구매 연결 (ex: 배달 API)

---

필요하다면 `.env`, CI/CD 설정, iOS/Android 배포까지 포함해 드릴 수 있어요. 추가로 원하시나요?
