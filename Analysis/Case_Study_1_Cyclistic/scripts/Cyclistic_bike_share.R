# Install and Load necessary libraries

install.packages("tidyverse")
library("tidyverse")

install.packages("DescTools")
library(DescTools)

install.packages("skimr")
library("skimr")

install.packages("janitor")
library("janitor")

install.packages("scales")
library("scales")

library("ggplot2")

library("lubridate")

library("readr")


getwd()

setwd("C:/Users/hp/OneDrive - AU-ATMIS/Desktop/Google Data Analytics Professional Certificate/CASE STUDY 1")

# Read the data
cleaned_2019 <- read_csv("cleaned_Divvy_2019_data.csv")
cleaned_2020 <- read_csv("cleaned_Divvy_2020_data.csv")

library("tidyverse")

glimpse(cleaned_2019)
glimpse(cleaned_2020)

#Confirm row Consistency
nrow(cleaned_2019)
nrow(cleaned_2020)

#Confirm Column Consistency
colnames(cleaned_2019)
colnames(cleaned_2020)

#Standardize 2020 Dataset
Divvy_2020_clean <- cleaned_2020 %>%
  select(
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    member_casual,
    ride_length,
    day_of_week
  )

#Standardize 2019 Dataset
Divvy_2019_clean <- cleaned_2019 %>%
  rename(
    ride_id = trip_id,
    started_at = start_time,
    ended_at = end_time,
    start_station_id = from_station_id,
    start_station_name = from_station_name,
    end_station_id = to_station_id,
    end_station_name = to_station_name,
    member_casual = member_casual
  ) %>%
  select(
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    member_casual,
    ride_length,
    day_of_week
  )

#Confirm Column Consistency
colnames(Divvy_2019_clean)
colnames(Divvy_2020_clean)

Divvy_2019_clean <- Divvy_2019_clean %>%
  mutate(
    # hms() parses "Hours:Minutes:Seconds"
    # as.numeric() then converts that period into total SECONDS
    ride_length = as.numeric(hms(ride_length))
  )

# Convert ride_length to numeric in the second dataframe
Divvy_2020_clean <- Divvy_2020_clean %>%
  mutate( ride_length = as.numeric(ride_length))

glimpse(Divvy_2019_clean)
glimpse(Divvy_2020_clean)

# Now try binding them again
#Merge the Datasets into a Single Dataframe
Cyclistic_bike_share <- bind_rows(Divvy_2019_clean, Divvy_2020_clean)


#Create the minutes column directly
Cyclistic_bike_share <- Cyclistic_bike_share %>%
  mutate(ride_length_minutes = ride_length / 60)

#Filter out data errors (negative times or trips longer than 24 hours)
Cyclistic_bike_share <- Cyclistic_bike_share %>%
  filter(ride_length_minutes > 0 & ride_length_minutes < 1440)

nrow(Cyclistic_bike_share)
mean(Cyclistic_bike_share$ride_length_minutes)
mean(Cyclistic_bike_share$ride_length) #This is in seconds
max(Cyclistic_bike_share$ride_length_minutes)

# The Pivot Table equivalent in R
rider_type_averages <- Cyclistic_bike_share %>%
  group_by(member_casual) %>%                         # "Rows" in Excel
  summarise(
    avg_ride_length_sec = mean(ride_length),          # "Values" (Average)
    avg_ride_length_min = mean(ride_length_minutes)   # "Values" (Average)
  )

# Display the results
print(rider_type_averages)

# Load library if not already loaded
library(tidyverse)

# Calculate the averages (The "Pivot Table" Logic)
ride_avg_pivot <- Cyclistic_bike_share %>%
  group_by(member_casual, day_of_week) %>%         # Rows and Columns
  summarise(avg_length = mean(ride_length_minutes, na.rm = TRUE), .groups = "drop") %>%
  
# Reshape the data to look like an Excel Table
  pivot_wider(names_from = day_of_week, values_from = avg_length)

# View the result
print(ride_avg_pivot)

glimpse(Cyclistic_bike_share)

write_csv(Cyclistic_bike_share, "Cyclistic_bike_share.csv")

#ANALYZE PHASE
#Run Descriptive Analysis (R Code)
#Rider type distribution - Shows how many rides were taken by:casual riders, annual members
Cyclistic_bike_share %>%
  count(member_casual)



# A. Temporal Analysis (The "When")

# I. DAY OF THE WEEK

# 1. Prepare the data
rides_by_day <- Cyclistic_bike_share %>%
  mutate(started_at = mdy_hm(started_at)) %>% 
  mutate(day_of_week = wday(started_at, label = TRUE, abbr = FALSE)) %>% 
  group_by(day_of_week, member_casual) %>% 
  summarise(number_of_rides = n(), .groups = 'drop')

# 2. Plot the results
ggplot(data = rides_by_day, aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") + # "dodge" places bars side-by-side
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Total Rides by Day of the Week",
    subtitle = "Comparing Weekday vs. Weekend usage",
    x = "Day of the Week",
    y = "Number of Rides",
    fill = "User Type"
  ) +
  theme_minimal()


# II. TIME OF THE DAY(HOURLY)

hourly_rides <- Cyclistic_bike_share %>%
  # Convert the character string to a real date-time object
  # If your data is YYYY-MM-DD, use ymd_hms. 
  # If it is MM/DD/YYYY, use mdy_hm.
  mutate(started_at = mdy_hm(started_at)) %>% 
  
# 1. Now extract the hour
  mutate(hour = hour(started_at)) %>% 
  group_by(hour, member_casual) %>% 
  summarise(number_of_rides = n(), .groups = 'drop')

# 2. Create the line plot
ggplot(data = hourly_rides, aes(x = hour, y = number_of_rides, color = member_casual)) +
  geom_line(size = 1.2) +                      # Create the line
  geom_point() +                               # Add points for clarity
  scale_x_continuous(breaks = seq(0, 23, 1)) + # Ensure every hour is marked
  scale_y_continuous(labels = scales::comma) + # Format numbers with commas
  labs(
    title = "Total Rides by Hour of Day",
    subtitle = "Comparing Members vs. Casual Riders",
    x = "Hour of Day (24-hour cycle)",
    y = "Number of Rides",
    color = "User Type"
  ) +
  theme_minimal()


# III. SEASONALITY:Analyze ride volume by month.

# 1. Convert, Extract, and Summarize
rides_by_month <- Cyclistic_bike_share %>%
  # FIRST: Tell R the format is Month/Day/Year Hour:Minute
  mutate(started_at = mdy_hm(started_at)) %>% 
  # SECOND: Extract the month label
  mutate(month = month(started_at, label = TRUE, abbr = TRUE)) %>% 
  group_by(month, member_casual) %>% 
  summarise(number_of_rides = n(), .groups = 'drop') %>% 
  # THIRD: Remove any rows that failed to parse (like headers or errors)
  filter(!is.na(month))

# 2. Plot the results
ggplot(data = rides_by_month, aes(x = month, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") + 
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Ride Volume by Month",
    subtitle = "Comparing seasonal trends between User Types",
    x = "Month",
    y = "Number of Rides",
    fill = "User Type"
  ) +
  theme_minimal()


# B. TRIP DURATION ANALYSIS (THE "HOW LONG")

# I. Average Trip Duration: Calculate the mean and median trip length for both groups.

# 1. Calculate duration and summarize
trip_duration_summary <- Cyclistic_bike_share %>%
  # Convert both time columns to date-time objects
  mutate(
    started_at = mdy_hm(started_at),
    ended_at = mdy_hm(ended_at)
  ) %>% 
  # Calculate duration in minutes
  mutate(ride_length_mins = as.numeric(difftime(ended_at, started_at, units = "mins"))) %>% 
  # Filter out potential data errors (negative durations or trips over 24 hours)
  filter(ride_length_mins > 0 & ride_length_mins < 1440) %>% 
  # Calculate Mean and Median
  group_by(member_casual) %>% 
  summarise(
    mean_duration = mean(ride_length_mins, na.rm = TRUE),
    median_duration = median(ride_length_mins, na.rm = TRUE)
  )

# View the results
print(trip_duration_summary)

# 2. Visualizing the Difference
# Plotting the mean duration
ggplot(trip_duration_summary, aes(x = member_casual, y = mean_duration, fill = member_casual)) +
  geom_col() +
  labs(
    title = "Average Trip Duration: Members vs. Casual Riders",
    subtitle = "Casual riders typically take much longer trips",
    x = "User Type",
    y = "Average Duration (Minutes)"
  ) +
  theme_minimal()


#TRIP DURATION DISTRIBUTION

# 1. Prepare the data and calculate durations
all_trips_duration <- Cyclistic_bike_share %>%
  mutate(
    started_at = mdy_hm(started_at),
    ended_at = mdy_hm(ended_at),
    ride_length_mins = as.numeric(difftime(ended_at, started_at, units = "mins"))
  ) %>% 
  # Filter out negative durations and extreme errors (trips > 24 hrs)
  filter(ride_length_mins > 0 & ride_length_mins < 1440)

# 2. Create the Histogram
# We limit the x-axis to 180 mins (3 hours) to make the distribution readable
ggplot(all_trips_duration, aes(x = ride_length_mins, fill = member_casual)) +
  geom_histogram(binwidth = 5, color = "white", alpha = 0.7) +
  facet_wrap(~member_casual, scales = "free_y") + # Separate plots to see shape clearly
  xlim(0, 180) + # Focus on the first 3 hours
  labs(
    title = "Distribution of Trip Durations (Up to 3 Hours)",
    subtitle = "Comparing the 'spread' between Members and Casual Riders",
    x = "Duration in Minutes (5-minute bins)",
    y = "Number of Trips",
    fill = "User Type"
  ) +
  theme_minimal()

# 3. STATISTICAL CHECK: Count the actual outliers (Trips > 3 hours)
outlier_analysis <- all_trips_duration %>%
  group_by(member_casual) %>%
  summarise(
    total_trips = n(),
    trips_over_3_hours = sum(ride_length_mins > 180),
    percentage_outliers = (trips_over_3_hours / total_trips) * 100
  )

print(outlier_analysis)

# 4. Refined Boxplot: The "Outlier" Visualizer
ggplot(all_trips_duration, aes(x = member_casual, y = ride_length_mins, fill = member_casual)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 1, outlier.alpha = 0.5) +
  # Use a log scale or limit y to see the boxes clearly while still showing outliers
  coord_cartesian(ylim = c(0, 200)) + 
  labs(
    title = "Trip Duration Range & Outliers",
    subtitle = "Red circles represent 'outlier' trips (Limited to 200 mins for view)",
    x = "User Type",
    y = "Duration (Minutes)"
  ) +
  theme_minimal()

# C. GEOSPATIAL ANALYSIS (The "Where")

# I. Top Stations: Identify the top 10 start and end stations for each group.
 
# 1. Calculate 10 top start stations for each group
top_start_stations <- Cyclistic_bike_share %>%
  # Filter out rows where station name is missing
  filter(!is.na(start_station_name) & start_station_name != "") %>%
  group_by(member_casual, start_station_name) %>%
  summarise(number_of_rides = n(), .groups = 'drop') %>%
  # Arrange and pick the top 10 for each group
  group_by(member_casual) %>%
  slice_max(order_by = number_of_rides, n = 10)

# 2. Visualize the results
ggplot(top_start_stations, aes(x = number_of_rides, y = reorder(start_station_name, number_of_rides), fill = member_casual)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~member_casual, scales = "free") +
  labs(
    title = "Top 10 Start Stations by User Type",
    subtitle = "Casuals favor landmarks; Members favor transit hubs",
    x = "Number of Rides",
    y = NULL
  ) +
  theme_minimal()

# 3. Finding the "Top Routes" (Start to End)
top_routes <- Cyclistic_bike_share %>%
  filter(!is.na(start_station_name) & !is.na(end_station_name)) %>%
  mutate(route = paste(start_station_name, "to", end_station_name)) %>%
  group_by(member_casual, route) %>%
  summarise(number_of_trips = n(), .groups = "drop") %>%
  group_by(member_casual) %>%
  slice_max(order_by = number_of_trips, n = 10)


print(top_routes)

write_csv(top_routes, "10 top routes for each group.csv")


# II. Popularity Routes

# 1. Identify the top 10 routes for each group
top_routes <- Cyclistic_bike_share %>%
  # Filter out missing station names
  filter(!is.na(start_station_name), !is.na(end_station_name),
         start_station_name != "", end_station_name != "") %>%
  # Create a 'Route' column
  mutate(route = paste(start_station_name, "to", end_station_name)) %>%
  group_by(member_casual, route) %>%
  summarise(number_of_trips = n(), .groups = "drop") %>%
  # Select the top 10 for each user type
  group_by(member_casual) %>%
  slice_max(order_by = number_of_trips, n = 10)

# 2. Plot the results
ggplot(top_routes, aes(x = number_of_trips, y = reorder(route, number_of_trips), fill = member_casual)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~member_casual, scales = "free") +
  labs(
    title = "Top 10 Most Popular Routes",
    subtitle = "Members: Utility/Commute Flow | Casuals: Recreational Flow",
    x = "Number of Trips",
    y = NULL
  ) +
  theme_minimal()

# 3. Identifying "Round Trips" vs. "Point-to-Point"
round_trip_stats <- Cyclistic_bike_share %>%
  filter(!is.na(start_station_name), !is.na(end_station_name)) %>%
  mutate(is_round_trip = (start_station_name == end_station_name)) %>%
  group_by(member_casual) %>%
  summarise(
    total_trips = n(),
    round_trips = sum(is_round_trip),
    percent_round_trip = (round_trips / total_trips) * 100
  )

print(round_trip_stats)
write.csv(round_trip_stats, "top routes summary.csv", row.names = FALSE)

write.csv(Cyclistic_bike_share, "Cyclistic_bike_share.csv", row.names = FALSE)


#Cyclistic_bike_share$ride_length_minutes <- as.numeric(Cyclistic_bike_share$ride_length_minutes)


#Number of rides by rider type
Cyclistic_bike_share %>%
  count(member_casual) %>%
  ggplot(aes(x = member_casual, y = n)) +
  geom_col() +
  labs(
    title = "Number of Rides by Rider Type",
    x = "Rider Type",
    y = "Number of Rides"
  )


#Calculate the average ride_length for users by day_of_week
Cyclistic_bike_share %>%
  group_by(member_casual, day_of_week) %>%
  summarise(avg_ride_length_min = mean(ride_length_minutes, na.rm = TRUE)) %>%
  ggplot(aes(x = day_of_week, y = member_casual, fill = avg_ride_length_min)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(
    title = "Average Ride Length by Rider Type and Day of Week",
    x = "Day of Week",
    y = "Rider Type",
    fill = "Avg Ride Length (min)"
  )


#Heatmap Visualization
Cyclistic_bike_share %>%
  group_by(member_casual, day_of_week) %>%
  summarise(num_rides = n()) %>%
  ggplot(aes(x = day_of_week, y = member_casual, fill = num_rides)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(
    title = "Number of Rides by Rider Type and Day of Week",
    x = "Day of Week (1 = Sunday, 7 = Saturday)",
    y = "Rider Type",
    fill = "Number of Rides"
  )


Cyclistic_bike_share %>%
  group_by(member_casual, day_of_week) %>%
  summarise(avg_ride_length_min = mean(ride_length_minutes, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = day_of_week, y = member_casual, fill = avg_ride_length_min)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(
    title = "Average Ride Length by Rider Type and Day of Week",
    x = "Day of Week (1 = Sunday, 7 = Saturday)",
    y = "Rider Type",
    fill = "Avg Length (min)"
  ) +
  theme_minimal()

