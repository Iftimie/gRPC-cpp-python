cmake_minimum_required(VERSION 3.22)
project(cppclient)

add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)

set(Protobuf_USE_STATIC_LIBS ON)

find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)

set(PROTO_FILES "message.proto")
add_executable( client client.cpp ${PROTO_FILES})

target_include_directories(client PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Protobuf_INCLUDE_DIR}
)

get_target_property(grpc_cpp_plugin_location gRPC::grpc_cpp_plugin LOCATION)
protobuf_generate(TARGET client LANGUAGE cpp)
protobuf_generate(
    TARGET
        client
    LANGUAGE
        grpc
    GENERATE_EXTENSIONS
        .grpc.pb.h
        .grpc.pb.cc
    PLUGIN
        "protoc-gen-grpc=${grpc_cpp_plugin_location}"
)

target_link_libraries(client
    protobuf::libprotobuf
    gRPC::grpc
    gRPC::grpc++
)
