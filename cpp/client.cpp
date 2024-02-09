#include <grpcpp/grpcpp.h>
#include "message.grpc.pb.h"
#include "message.pb.h"

int main() {
  std::string connection = "127.0.0.1:50000";
  std::shared_ptr<grpc::Channel> channel = grpc::CreateChannel(connection.c_str(), grpc::InsecureChannelCredentials());
  auto stub = grpctemplate::MyService::NewStub(channel);

  grpc::ClientContext context;
  grpctemplate::RequestHello query;
  query.set_name("Alex");
  grpctemplate::ResponseHello result;
  try {
    grpc::Status status = stub->SayHello(&context, query, &result);
    std::cout << status.error_message() << std::endl;
    std::cout << result.output() << std::endl;
  } catch (const std::exception& ex) {
    std::cerr << "Exception caught: " << ex.what() << std::endl;
  }
  std::cout << "Done" << std::endl;
  return 0;
}
