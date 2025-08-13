Окей, давай зробимо інший приклад .NET 8 API — простий ToDo API з CRUD-операціями, який точно працюватиме і локально, і в контейнері, без HTTPS-редіректів.

## 1. Створення проєкту

```bash
dotnet new webapi -n TodoApi --no-https
cd TodoApi
```

Прапорець `--no-https` одразу вимикає HTTPS-редірект.

## 2. Program.cs (мінімальний CRUD)

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Swagger завжди
app.UseSwagger();
app.UseSwaggerUI();

var todos = new List<TodoItem>();

app.MapGet("/todos", () => todos);

app.MapGet("/todos/{id}", (int id) =>
    todos.FirstOrDefault(t => t.Id == id) is TodoItem todo
        ? Results.Ok(todo)
        : Results.NotFound());

app.MapPost("/todos", (TodoItem todo) =>
{
    todo.Id = todos.Count > 0 ? todos.Max(t => t.Id) + 1 : 1;
    todos.Add(todo);
    return Results.Created($"/todos/{todo.Id}", todo);
});

app.MapPut("/todos/{id}", (int id, TodoItem updatedTodo) =>
{
    var todo = todos.FirstOrDefault(t => t.Id == id);
    if (todo is null) return Results.NotFound();
    todo.Title = updatedTodo.Title;
    todo.IsComplete = updatedTodo.IsComplete;
    return Results.Ok(todo);
});

app.MapDelete("/todos/{id}", (int id) =>
{
    var todo = todos.FirstOrDefault(t => t.Id == id);
    if (todo is null) return Results.NotFound();
    todos.Remove(todo);
    return Results.NoContent();
});

app.Run();

record TodoItem
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public bool IsComplete { get; set; }
}
```

## 3. Dockerfile

```dockerfile
# Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish --no-restore

# Final
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "TodoApi.dll"]
```

## 4. Збірка і запуск

```bash
docker build -t <login>/todoapi:1.0 .
docker run --rm -p 8080:80 <login>/todoapi:1.0
```

## 5. Перевірка

- **Swagger**: `http://localhost:8080/swagger`

Отримати список ToDo:

```bash
curl http://localhost:8080/todos
```

Додати ToDo:

```bash
curl -X POST http://localhost:8080/todos -H "Content-Type: application/json" -d "{\"title\":\"Learn 
```