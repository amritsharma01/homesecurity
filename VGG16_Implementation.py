import tensorflow as tf
import cv2
import os
import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.applications.vgg16 import VGG16
from tensorflow.keras.applications.vgg16 import preprocess_input
from tensorflow.keras import layers,models

gpus=tf.config.experimental.list_physical_devices('GPU')
for gpu in gpus:
    tf.config.experimental.set_memory_growth(gpu,True)
    
    
def normalize_img(image,labels):
    return(tf.cast(image,tf.float32)/255.0,labels)

def extract_data(path): #Here path is the str() data type. Path to the data,where folder name is label
    path=path
    Images=[]
    labels=[]

    for i in [i for i in os.listdir(path)]:
        data_path=path+str(i)
        filenames=[i for i in os.listdir(data_path)]
        
        for file in filenames:
            img=cv2.imread(data_path+'/'+file)
            Images.append(img)
            labels.append(i)
    
    return np.array(Images),np.array(labels)
        

Images,labels=extract_data('Data/')
from sklearn.preprocessing import LabelEncoder,OneHotEncoder
from sklearn.compose import ColumnTransformer

y_labelencoder=LabelEncoder()
y=y_labelencoder.fit_transform(labels)

y=y.reshape(-1,1)

columnTransformer = ColumnTransformer([('encoder', OneHotEncoder(), [0])],remainder='passthrough')
Y=np.array(columnTransformer.fit_transform(y))


from sklearn.model_selection import train_test_split
train_x,test_x,train_y,test_y=train_test_split(Images,Y,test_size=0.2,random_state=300)


#Prepare Datasets following tensorflow data pipeline

train_dataset=tf.data.Dataset.from_tensor_slices((train_x,train_y))
train_dataset=train_dataset.map(normalize_img,num_parallel_calls=tf.data.AUTOTUNE)
train_dataset=train_dataset.cache()
train_dataset=train_dataset.shuffle(len(train_dataset))
train_dataset=train_dataset.batch(8)
train_dataset=train_dataset.prefetch(tf.data.AUTOTUNE)

#Prepare Test dataset
test_dataset=tf.data.Dataset.from_tensor_slices((test_x,test_y))
test_dataset=test_dataset.map(normalize_img,num_parallel_calls=tf.data.AUTOTUNE)
test_dataset=test_dataset.batch(8)
test_dataset=test_dataset.cache()
test_dataset=test_dataset.prefetch(tf.data.AUTOTUNE)

#Import VGG16
base_model=VGG16(weights='imagenet',include_top=False,input_shape=(224,224,3))
base_model.trainable=False

#Create Dense Layer   

model=tf.keras.Sequential([
    base_model,
    layers.Flatten(),
    layers.Dense(2096,activation='relu'),
    layers.Dense(2096,activation='relu'),
    layers.Dense(3,activation='softmax') 
])
model.summary()
model.compile(
    optimizer='adam',
    loss='BinaryCrossentropy',
    metrics=["accuracy"]  
)

model.fit(train_dataset,epochs=10)
model.evaluate(test_dataset)

#Validate model
img=cv2.imread("Validation/image125.jpg")
feature=model.predict(np.array([img]))
print(feature.shape)

for x in feature :
    for k in x:
        print(k)

if (feature.max()==feature[0,2]):
    print("This is Biraj")
if (feature.max()==feature[0,1]):
    print("This is Ashim")
if (feature.max()==feature[0,0]):
    print("This is Amrit")
