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
