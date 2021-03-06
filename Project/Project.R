library(caret)
library(foreach)

# Getting the data and partitioning
setwd("D:/Mes documents/Coursera/Practical Machine Learning/Project")
#setwd("C:/Documents and Settings/jean-pierre.sylvan/Mes documents/Practical_ML/Project")
pml_training=read.csv(file="pml-training.csv",header=T,sep=,)
pml_training=pml_training[,-1]
pml_testing=read.csv(file="pml-testing.csv",header=T,sep=,)
pml_testing=pml_testing[,-1]
inTrain = createDataPartition(pml_training$classe, p = 3/4)[[1]]
training = pml_training[inTrain,]
testing = pml_training[-inTrain,]

#We keep only the feature which are not factors, anyway the factor feature are all empty
#And only the features where mean(is.na)<90%

num_NA=vector(mode="numeric",length=dim(training)[2])
for (i in 1:length(num_NA)) {
  num_NA[i] = mean(is.na(training[,i]))
}

Type=character(dim(training)[2])
for (i in 1:length(Type)) {
  Type[i] = class(training[,i])
}
Num = (Type == "numeric")|(Type == "integer")

training_classe=training$classe
testing_classe=testing$classe
training=training[,(num_NA<0.9)&Num] #training doesn't contain classe so we mustn't forget it later
testing=testing[,(num_NA<0.9)&Num] #Same for testing

# PCA and model
pca=preProcess(x=training,method="pca",thresh=0.9)
print(pca)
trainPC = predict(pca,training)
#modFit = train(pml_training$classe~.,data=trainPC,method="rf")
testPC = predict(pca,newdata=testing)
modFit = train(training_classe~.,data=trainPC,method="rf")
predict(modFit,newdata=testPC)
confusionMatrix(testing_classe,predict(modFit,newdata=testPC))

# Pr?diction de classe sur la table pml_testing avec modFit
pml_testing2=pml_testing[,(num_NA<0.9)&Num]
pml_testing2PC=predict(pca,newdata=pml_testing2)
predict(modFit,newdata=pml_testing2PC)

# On peut aussi lancer le modele sur la table entiere, maintenant qu'on sait
#qu'il est valable

pml_training = read.csv(file="pml-training.csv",header=T,sep=,)
pml_training=pml_training[,-1]
table = pml_training[,Num & (num_NA<0.9)]
pca=preProcess(x=table,method="pca",thresh=0.9)
trainPC = predict(pca,table)
modFit = train(pml_training$classe~.,data=trainPC,method="rf")

# Prediction de classe sur la table pml_testing avec modFit
pml_testing2=pml_testing[,(num_NA<0.9)&Num]
pml_testing2PC=predict(pca,newdata=pml_testing2)
predict(modFit,newdata=pml_testing2PC)