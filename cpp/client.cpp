#include <grpcpp/grpcpp.h>
#include "message.grpc.pb.h"
#include "message.pb.h"
#include <fstream>

struct Pixel {
    uint8_t r, g, b;
};
class PPMImage {
public:
    std::vector<Pixel> pixels;
    int width, height;

    PPMImage(const std::string& filename) {
        std::ifstream file(filename, std::ios::binary);
        if (!file.is_open()) {
            throw std::runtime_error("Could not open file");
        }
        std::string line;
        std::getline(file, line);
        if (line != "P6") {
            throw std::runtime_error("Unsupported format or not a P6 PPM");
        }
        while (file.peek() == '#') {
            std::getline(file, line);
        }
        file >> width >> height;
        int maxVal;
        file >> maxVal;
        file.ignore(256, '\n');
        pixels.resize(width * height);
        file.read(reinterpret_cast<char*>(pixels.data()), pixels.size() * sizeof(Pixel));
    }
};

int main() {
  std::string connection = "127.0.0.1:50000";
  std::shared_ptr<grpc::Channel> channel = grpc::CreateChannel(connection.c_str(), grpc::InsecureChannelCredentials());
  auto stub = grpctemplate::MyService::NewStub(channel);

  auto image = PPMImage("image.ppm");

  grpc::ClientContext context;
  grpctemplate::RequestHello query;
  query.set_name("Alex");
  grpctemplate::Image* proto_image = query.mutable_image();
  proto_image->set_data(reinterpret_cast<char*>(image.pixels.data()), image.pixels.size() * sizeof(Pixel));
  proto_image->set_width(image.width);
  proto_image->set_height(image.height);
  proto_image->set_channels(3);

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
