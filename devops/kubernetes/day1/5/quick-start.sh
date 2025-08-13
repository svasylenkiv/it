#!/bin/bash

echo "🚀 Швидкий старт Ingress для TodoAPI"
echo "======================================"

# Перевірка передумов
echo "📋 Перевірка передумов..."
echo ""

# Перевірка Deployment
echo "1. Перевірка Deployment..."
kubectl get deployment todoapi-deployment
echo ""

# Перевірка Service
echo "2. Перевірка Service..."
kubectl get svc todoapi-service
echo ""

# Перевірка Pods
echo "3. Перевірка Pods..."
kubectl get pods -l app=todoapi
echo ""

# Перевірка Endpoints
echo "4. Перевірка Endpoints..."
kubectl get endpoints todoapi-service
echo ""

# Перевірка Ingress Controller
echo "5. Перевірка Ingress Controller..."
kubectl get pods -n ingress-nginx
echo ""

echo "======================================"
echo "🔧 Налаштування Ingress..."

# Застосування Ingress
echo "Застосовуємо Ingress..."
kubectl apply -f todoapi-ingress.yaml

echo ""
echo "⏳ Чекаємо готовності Ingress..."
sleep 10

# Перевірка Ingress
echo "Перевірка Ingress..."
kubectl get ingress
echo ""

# Отримання IP
echo "🌐 Отримуємо IP minikube..."
MINIKUBE_IP=$(minikube ip)
echo "IP minikube: $MINIKUBE_IP"
echo ""

echo "======================================"
echo "📝 Наступні кроки:"
echo ""
echo "1. Додай в C:\\Windows\\System32\\drivers\\etc\\hosts:"
echo "   $MINIKUBE_IP myapi.local"
echo ""
echo "2. Тестуй API:"
echo "   curl http://myapi.local/todos"
echo "   curl http://myapi.local/swagger"
echo ""
echo "3. Для HTTPS використай:"
echo "   kubectl apply -f todoapi-ingress-tls.yaml"
echo ""
echo "======================================"
echo "✅ Готово! TodoAPI доступний через Ingress!" 