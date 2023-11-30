import os
import tempfile

from fastapi import FastAPI, Request, File, UploadFile, Form
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from starlette.responses import RedirectResponse

from to_pip import to_pip

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return RedirectResponse("./static/html/index.html")


@app.post("/api/upload")
async def upload_files(
        package_name: str = Form(...),
        package_version: str = Form(...),
        pypi_username: str = Form(""),
        pypi_password: str = Form(""),
        python_files: list[UploadFile] = File(...),
        readme: UploadFile = File(None),
        requirements: UploadFile = File(None)
):
    tmp_dir = tempfile.mkdtemp()
    saved_files = []

    for file in python_files:
        file_path = os.path.join(tmp_dir, file.filename)
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        saved_files.append(file_path)

    if readme:
        readme_path = os.path.join(tmp_dir, "../README.md")
        with open(readme_path, "wb") as buffer:
            content = await readme.read()
            buffer.write(content)

    if requirements:
        requirements_path = os.path.join(tmp_dir, "../requirements.txt")
        with open(requirements_path, "wb") as buffer:
            content = await requirements.read()
            buffer.write(content)

    # Save the original working directory
    original_cwd = os.getcwd()

    # Change the current working directory to the temporary directory
    os.chdir(tmp_dir)

    try:
        # Call the to_pip() function with the saved files
        to_pip(saved_files, package_name, package_version, pypi_username, pypi_password)
    finally:
        # Restore the original working directory
        os.chdir(original_cwd)

    return JSONResponse({"message": "Package uploaded and processed successfully"})
