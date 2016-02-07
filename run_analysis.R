#rm(list=ls())
library(reshape2)

pth.dir.root = 'specdata/UCI HAR Dataset'
pth.dir.test = 'test'
pth.dir.train = 'train'

pth.file.test.x = 'X_test.txt'
pth.file.test.y = 'y_test.txt'
pth.file.test.subject = 'subject_test.txt'

pth.file.train.x = 'X_train.txt'
pth.file.train.y = 'y_train.txt'
pth.file.train.subject = 'subject_train.txt'

pth.file.activity.labels = 'activity_labels.txt'
pth.file.features = 'features.txt'

pth.file.tidy = 'tidy_data.txt'


#-------------------------------------------------------------------------------
# read activity labels and features
#
activity.labels = read.table(file.path(pth.dir.root,
                                       pth.file.activity.labels)
)
features = read.table(file.path(pth.dir.root, pth.file.features))


#-------------------------------------------------------------------------------
# read train data
#
train.x = read.table(file.path(pth.dir.root,
                               pth.dir.train,
                               pth.file.train.x)
)
train.y = read.table(file.path(pth.dir.root,
                               pth.dir.train,
                               pth.file.train.y)
)
train.subject = read.table(file.path(pth.dir.root,
                                     pth.dir.train,
                                     pth.file.train.subject)
)


#-------------------------------------------------------------------------------
# read test data
#
test.x = read.table(file.path(pth.dir.root,
                              pth.dir.test,
                              pth.file.test.x)
)
test.y = read.table(file.path(pth.dir.root,
                              pth.dir.test,
                              pth.file.test.y)
)
test.subject = read.table(file.path(pth.dir.root,
                                    pth.dir.test,
                                    pth.file.test.subject)
)


#-------------------------------------------------------------------------------
# merge and label datasets
#
all.x = rbind(test.x, train.x)
colnames(all.x) = features[,2]

all.label = rbind(test.y, train.y)
all.label = as.dataframe(merge(all.label, activity.labels, by = 1)[,2])
colnames(all.label) = c("label")

all.subject = rbind(test.subject, train.subject)
colnames(all.subject) = c("subject")

dt.merged = cbind(all.subject, all.label, all.x)


#-------------------------------------------------------------------------------
# filter mean and standard deviation
#
ids.stdev = grep('-std', features[,2], fixed = TRUE)
ids.mean = grep('-mean', features[,2], fixed = TRUE)

# don't forget about subject and label cols c(1, 2, ...)
dt.mean_std = dt.merged[, c(1, 2, ids.stdev, ids.mean)]


#-------------------------------------------------------------------------------
# creating new data set
#
dt.mean_std.melted = melt(dt.mean_std, id.vars = colnames(dt.mean_std[,1:2]))
dt.tidy = dcast(dt.mean_std.melted, subject + label ~ variable, mean)

write.table(dt.tidy, file.path(pth.dir.root, pth.file.tidy))
