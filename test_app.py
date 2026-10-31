from app import app

def test_home():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200

def test_add_todo():
    client = app.test_client()

    response = client.post(
        "/todos",
        json={"task": "Learn Jenkins"}
    )

    assert response.status_code == 201
    assert response.json["task"] == "Learn Jenkins"

def test_get_todos():
    client = app.test_client()
    response = client.get("/todos")

    assert response.status_code == 200
