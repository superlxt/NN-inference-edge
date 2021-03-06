# CXXCL := toolchain/aarch64-unknown-linux-gnu/bin/aarch64-unknown-linux-gnu-g++
CXXCL := g++
NVCXX := nvcc

CXXFLAGS := -O3 -std=c++17
CXXFLAGS += -fomit-frame-pointer -fstrict-aliasing -ffast-math -fvisibility=hidden -fvisibility-inlines-hidden -fno-rtti
NVCXXFLAGS := -O3 -std=c++14

CUDA_ARCH := -gencode arch=compute_53,code=sm_53 -gencode arch=compute_62,code=sm_62 -gencode arch=compute_72,code=sm_72

INCLUDES := -I src
INCLUDES += -I /usr/include/opencv4
INCLUDES += -I libraries/spdlog/include
INCLUDES += -I libraries/nlohmann-json
INCLUDES += -I libraries/RxCpp/Rx/v2/src
INCLUDES += -I /usr/local/cuda/include

# DEFINES := -D NDEBUG


LDFLAGS := -L/usr/lib/aarch64-linux-gnu
LDFLAGS += -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio -lopencv_dnn
# LDFLAGS += -lglog -lboost_system
LDFLAGS += -lnvinfer -lnvparsers -lcuda -lnvinfer_plugin -lnvonnxparser
LDFLAGS += -L/usr/local/cuda-10.2/targets/aarch64-linux/lib
LDFLAGS += -lcudart
LDFLAGS += -pthread -lm -lstdc++fs

OBJROOT := obj

SRCFILES := $(wildcard src/*.cpp)
SRCFILES += $(wildcard src/nv/*.cpp)
SRCFILES += $(wildcard src/nie/*.cpp)
SRCFILES += $(wildcard src/nie/*.cu)



# EXAMPLEFILES := examples/bisenet.cpp
# EXAMPLEFILES := examples/mobilenetv2ssd.cpp
# EXAMPLEFILES := examples/espnet-video.cpp
# EXAMPLEFILES := examples/espnet-async.cpp
# EXAMPLEFILES := examples/main-create-engine.cpp
# EXAMPLEFILES := examples/main-engine-fps.cpp
# EXAMPLEFILES := examples/main-multiple.cpp
EXAMPLEFILES := examples/espnet.cpp


OBJS := $(addprefix $(OBJROOT)/, $(patsubst %.cu, %.o, $(patsubst %.cpp, %.o, $(SRCFILES) $(EXAMPLEFILES))))

# $(error LHH: '$(OBJS)')


APP_NAME := primus




all: obj $(OBJS)
	$(CXXCL) $(SHAREDPATH) $(OBJS) $(LDFLAGS) -o $(APP_NAME)

$(OBJROOT)/%.o: %.cpp
	$(CXXCL) -c -pipe $(CXXFLAGS) $(DEFINES) $(INCLUDES) $< -o $@
$(OBJROOT)/%.o: %.cu
	$(NVCXX) -c $(NVCXXFLAGS) $(CUDA_ARCH) $(DEFINES) $(INCLUDES) $< -o $@

obj:
	mkdir -vp $(OBJROOT) $(dir $(OBJS))

.PHONY: clean obj

clean:
	rm -rf $(OBJROOT) $(APP_NAME)
