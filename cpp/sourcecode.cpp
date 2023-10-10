#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>

// Define a structure to hold the delivery location data
struct DeliveryLocation {
    int id;
    double x, y;
    int priority;
    int time_window_start, time_window_end;
};

// Define a function to calculate the distance between two delivery locations
double distance(DeliveryLocation a, DeliveryLocation b) {
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
}

// Define a function to find the nearest neighbor of a given delivery location
int find_nearest_neighbor(DeliveryLocation location, std::vector<DeliveryLocation>& locations) {
    int nearest_neighbor_index = -1;
    double min_distance = INFINITY;
    for (int i = 0; i < locations.size(); i++) {
        if (distance(location, locations[i]) < min_distance) {
            min_distance = distance(location, locations[i]);
            nearest_neighbor_index = i;
        }
    }
    return nearest_neighbor_index;
}

// Define the main function
int main() {
    // Define the delivery locations
    std::vector<DeliveryLocation> delivery_locations = {
        {1, 0, 0, 1, 0, 10},
        {2, 1, 0, 2, 0, 10},
        {3, 0, 1, 3, 0, 10},
        {4, 1, 1, 4, 0, 10},
    };

    // Define the starting location
    DeliveryLocation starting_location = {0, 0, 0, 0, 0, 10};

    // Define a vector to hold the delivery route
    std::vector<DeliveryLocation> route;

    // Add the starting location to the route
    route.push_back(starting_location);

    // Iterate over the delivery locations and add them to the route in the order of their nearest neighbor
    while (delivery_locations.size() > 0) {
        int nearest_neighbor_index = find_nearest_neighbor(route.back(), delivery_locations);
        route.push_back(delivery_locations[nearest_neighbor_index]);
        delivery_locations.erase(delivery_locations.begin() + nearest_neighbor_index);
    }

    // Print the delivery route
    std::cout << "Delivery Route:" << std::endl;
    for (int i = 0; i < route.size(); i++) {
        std::cout << route[i].id << " ";
    }
    std::cout << std::endl;

    return 0;
}