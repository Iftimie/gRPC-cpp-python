FROM ubuntu:latest

RUN apt-get update && apt-get install -y git curl zip unzip tar cmake build-essential pkg-config python3 python3-pip
RUN git clone https://github.com/microsoft/vcpkg.git
ENV CMAKE_TOOL_CHAIN=/vcpkg/scripts/buildsystems/vcpkg.cmake
RUN echo "set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=0\")" >> $CMAKE_TOOL_CHAIN
RUN ./vcpkg/bootstrap-vcpkg.sh
RUN ./vcpkg/vcpkg install grpc --triplet x64-linux-release

RUN python3 -m pip install grpcio-tools

WORKDIR /app
ADD message.proto message.proto
RUN mkdir py
RUN python3 -m grpc_tools.protoc --proto_path=. --python_out=py --grpc_python_out=py message.proto
ADD py/server.py py/server.py


RUN mkdir cpp
ADD cpp/client.cpp cpp/client.cpp
ADD cpp/CMakeLists.txt cpp/CMakeLists.txt
ADD message.proto cpp/message.proto
RUN mkdir cpp/build && cd cpp/build && cmake -DVCPKG_TARGET_TRIPLET=x64-linux-release -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOL_CHAIN .. && make

ADD start.sh start.sh
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]