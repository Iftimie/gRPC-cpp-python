cmake_minimum_required(VERSION 3.22)
project(cppclient)

set(Protobuf_USE_STATIC_LIBS ON)

find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)

add_executable( client client.cpp message.grpc.pb.cc message.pb.cc)

target_include_directories(client PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Protobuf_INCLUDE_DIR}
)

target_link_libraries(client
    protobuf::libprotobuf
    gRPC::grpc
    gRPC::grpc++
)
