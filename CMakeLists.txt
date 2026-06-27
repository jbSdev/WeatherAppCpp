cmake_minimum_required(VERSION 3.16)
project(weather-api VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find dependencies
find_package(CURL REQUIRED)

# Crow
include(FetchContent)

FetchContent_Declare(
    crow
    GIT_REPOSITORY  https://github.com/CrowCpp/Crow.git
    GIT_TAG         v1.2.0
)
FetchContent_MakeAvailable(crow)

FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY  https://github.com/nlohmann/json.git
    GIT_TAG         v3.11.3
)
FetchContent_MakeAvailable(nlohmann_json)

add_executable(weather-api src/main.cpp)

target_link_libraries( weather-api
    PRIVATE
        Crow::Crow
        CURL::libcurl
        nlohmann_json::nlohmann_json
)

target_compile_options(weather-api PRIVATE -02 -Wall)
