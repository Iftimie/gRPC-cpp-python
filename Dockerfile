FROM ubuntu:latest

RUN apt-get update && apt-get install -y git curl zip unzip tar cmake build-essential pkg-config python3
RUN git clone https://github.com/microsoft/vcpkg.git
RUN ./vcpkg/bootstrap-vcpkg.sh
RUN ./vcpkg/vcpkg install grpc --triplet x64-linux-release

RUN apt-get install -y python3-pip
RUN python3 -m pip install grpcio-tools

WORKDIR /app
ADD message.proto message.proto
RUN mkdir py
RUN python3 -m grpc_tools.protoc --proto_path=. --python_out=py --grpc_python_out=py message.proto
ADD py/server.py py/server.py


ENV PROTOC_PATH=/vcpkg/installed/x64-linux-release/tools/protobuf/protoc
ENV GRPC_CPP_PLUGIN=/vcpkg/installed/x64-linux/tools/grpc/grpc_cpp_plugin
RUN mkdir cpp
RUN $PROTOC_PATH --cpp_out=cpp --grpc_out=cpp --plugin=protoc-gen-grpc=$GRPC_CPP_PLUGIN message.proto

ADD cpp/client.cpp cpp/client.cpp
ADD cpp/CMakeLists.txt cpp/CMakeLists.txt
ENV CMAKE_TOOL_CHAIN=/vcpkg/scripts/buildsystems/vcpkg.cmake
RUN mkdir cpp/build && cd cpp/build && cmake -DVCPKG_TARGET_TRIPLET=x64-linux-release -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOL_CHAIN .. && make

ADD start.sh start.sh
RUN chmod +x start.sh
ENTRYPOINT ["./start.sh"]
