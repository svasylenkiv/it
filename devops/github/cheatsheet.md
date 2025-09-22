🔹 Налаштування
git config --global user.name "Твоє Ім'я"
git config --global user.email "твій@email.com"

🔹 Клонування репозиторію
git clone https://github.com/user/repo.git
cd repo

🔹 Перевірка статусу
git status

🔹 Додавання змін

Додати усі зміни:

git add .


Додати лише конкретний файл:

git add filename.txt

🔹 Коміт
git commit -m "Опис змін"

🔹 Відправка змін на GitHub
git push origin main


(якщо гілка називається master, то замість main пиши master)

🔹 Оновлення локального репо
git pull origin main

🔹 Створення нової гілки
git checkout -b new-branch

🔹 Перехід у гілку
git checkout branch-name

🔹 Об’єднання гілки
git merge branch-name