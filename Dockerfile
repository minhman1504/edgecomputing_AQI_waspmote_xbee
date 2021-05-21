FROM python:3.7

WORKDIR /app

COPY ./script.py .
COPY ./parameters.py .
COPY ./requirements.txt .

RUN pip3 install -r ./requirements.txt 

CMD ["python3", "-u", "./script.py"]