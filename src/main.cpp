#include "crow.h"
#include <curl/curl.h>
#include <exception>
#include <nlohmann/json.hpp>
#include <string>
#include <cstdlib>

using json = nlohmann::json;

static size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* output)
{
    output -> append(static_cast<char*>(contents), size * nmemb);
    return size * nmemb;
}

std::string fetchWeather(const std::string& apiKey)
{
    CURL* curl = curl_easy_init();
    if (!curl) return R"({"error":"Failed to init curl"})";

    std::string url = "https://api.openweathermap.org/data/2.5/weather"
                      "?q=Warsaw,PL&appid=" + apiKey + "&units=metric";
    std::string response;

    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10L);

    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK)
        return R"({"error":"curl request failed: )" + std::string(curl_easy_strerror(res)) + "\"}";

    return response;
}

int main()
{
    const char* apiKey = std::getenv("OWM_API_KEY");
    if (!apiKey)
    {
        std::cerr << "ERROR: OWM_API_KEY env variable not set\n";
        return -1;
    }

    crow::SimpleApp app;

    CROW_ROUTE(app, "/weather")([ apiKey ]() {
        std::string raw = fetchWeather(apiKey);

        try {
            auto data = json::parse(raw);
            json result = {
                {"city",        data["name"]},
                {"country",     data["sys"]["country"]},
                {"temperature", data["main"]["temp"]},
                {"feels_like",  data["main"]["feels_like"]},
                {"humidity",    data["main"]["humidity"]},
                {"description", data["weather"][0]["description"]},
                {"wind_speed",  data["wind"]["speed"]}
            };

            crow::response resp(200, result.dump(2));
            resp.add_header("Content-Type", "application/json");
            return resp;
        } catch (const std::exception& e) {
            json err = {{"error", "Failed to parse weather data"}, {"detail", e.what()}};
            crow::response resp(500, err.dump());
            resp.add_header("Content-Type", "application/json");
            return resp;
        }
    });

    CROW_ROUTE(app, "/health")([] {
        crow::response resp(200, R"({"status":"ok"})");
        resp.add_header("Content-Type", "application/json");
        return resp;
    });

    app.port(8080).multithreaded().run();
    return 0;
}
