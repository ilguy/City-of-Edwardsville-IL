# Sort the data
RunningDF <- RunningDF[with(RunningDF, order(Date)),]

# Give an initial line plot
plot(Amount ~ Date, RunningDF, type = "l")