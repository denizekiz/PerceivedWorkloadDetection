import keras
from keras.layers import LSTM
model = Sequential()
model.add(LSTM(neurons, input_shape=(x_train.shape[1],x_train.shape[2]),recurrent_dropout=dropout))
model.add(Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
history = model.fit(x_train[train,:],
                          y_train[train,],
                          batch_size=BATCH_SIZE,
                          epochs=EPOCHS,
                          validation_data=(x_train[test,:], y_train[test,]),
                          verbose=0)