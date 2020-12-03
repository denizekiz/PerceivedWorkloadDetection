import keras
from keras.layers import Conv1D
from keras.layers import Conv2D
from keras.layers import Dropout, MaxPooling1D, MaxPooling2D
model = Sequential()
model.add(Conv2D(filters=15, kernel_size=(3,3),activation='relu', input_shape=(575,4,1)))
model.add(MaxPooling2D(pool_size=(4,2)))
model.add(Conv2D(filters=25, kernel_size=(4,1),activation='relu'))
model.add(MaxPooling2D(pool_size=(2,1)))
model.add(Conv2D(filters=40, kernel_size=(4,1),activation='relu'))
model.add(Flatten())
model.add(Dense(256, activation='relu'))
model.add(Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy', optimizer='Adagrad', metrics=['accuracy'])
history = model.fit(x_train[train,:,:,:],
                              y_train[train],
                              batch_size=BATCH_SIZE,
                              epochs=EPOCHS,
                              validation_data=(x_train[test,:], y_train[test]),
                              verbose=0)