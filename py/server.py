from concurrent import futures
import message_pb2_grpc
import message_pb2
import numpy as np
import grpc
import time
import cv2

class MyServiceServicerImpl(message_pb2_grpc.MyServiceServicer):
    def __init__(self) -> None:
        super().__init__()

    def SayHello(self, request: message_pb2.RequestHello, context):
        print(f"Received request from {request.name}")
        img = np.fromstring(request.image.data, dtype='uint8')
        img = np.reshape(img, (request.image.height, request.image.width, request.image.channels))
        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

        cv2.imwrite("/output/server_image.jpg", img)

        response = message_pb2.ResponseHello()
        response.output = "Hello " + request.name + "!"
        response.image.height = img.shape[0]
        response.image.width = img.shape[1]
        response.image.channels = img.shape[2]
        response.image.data = img.tobytes()
        return response

def serve():
    pool = futures.ThreadPoolExecutor(max_workers=1)
    server = grpc.server(pool, maximum_concurrent_rpcs=10)
    message_pb2_grpc.add_MyServiceServicer_to_server(MyServiceServicerImpl(), server)
    server.add_insecure_port('[::]:50000')
    server.start()
    while True:
        print(f"Requests in queue: {pool._work_queue.qsize()}")
        time.sleep(5)

if __name__ == '__main__':
    serve()