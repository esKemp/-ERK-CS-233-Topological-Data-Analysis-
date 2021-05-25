# ------------------------
# CS233 HW1
# Problem 2  Starter Code
# ------------------------

import numpy as np
import os
from scipy.io import loadmat
import scipy.linalg


def multiview_CCA_train(XtX, CCAdim, nViews, featdim):
    '''
    Computing CCA transformation matrices and eigenvalues, as a generalized EV problem
    Input: 
     - XtX is the nViews*nViews list which stores X.T * X
     - CCAdim is the desired CCA dimension
    Output:
     - A contains the trained CCA projection matrices
     - L is a vector storing the eigenvalues
    '''
    nViews = len(XtX)
    # dims = np.array([XtX[i][i].shape[0] for i in range(nViews)])

    # ------------------------------------------
    # TODO: Assemble covariance matrices and solve the 
    # generalized eigenvalue problem (use scipy.linalg.eig).
    # Hint: eigenvalues/eigenvectors returned by eig are not in sorted order, so
    #       you must make sure the eigenvalues are in descending order such that the projections
    #       correspond to the ordering from largest to smallest eigenvalues

    M = np.zeros([nViews*featdim, nViews*featdim])
    B = np.zeros([nViews*featdim, nViews*featdim])

    for i in range(0, nViews):
        for j in range(0, nViews):
            rowStart = i*featdim 
            rowEnd = i*featdim + featdim 
            colStart = j*featdim 
            colEnd = j*featdim + featdim 
            if i == j:
                B[rowStart:rowEnd, colStart:colEnd] = XtX[i][j]
            elif i < j:
                M[rowStart:rowEnd, colStart:colEnd] = XtX[i][j]
            else:
                M[rowStart:rowEnd, colStart:colEnd] = np.transpose(XtX[j][i])
    
    Lvals, Avecs = scipy.linalg.eigh(M, B)
    Lvals = np.flip(Lvals)[0:CCAdim]
    Avecs = np.flip(Avecs, axis=1)[:,0:CCAdim]

    A = []
    for i in range(3):
        start = i*featdim
        finish = i*featdim + featdim 
        A.append(Avecs[start:finish, :])

    # A = [...] # a list of np.arrays, where A[i] is of dimension dims[i]*CCAdim
    L = Lvals # L is an np.array of dimension CCAdim

    return A, L

#
# Train multiview CCA
#

# configuration
featdim = 200 # feature dimensions (of input PCA features)
CCAdim = 100 # desired CCA dimension, note that CCAdim < featdim*nViews

# load database features, which are already PCA transformed into 200 dimensions
data_path = './data_p2'
X = loadmat(os.path.join(data_path, 'DatabaseFeature_small.mat'), simplify_cells=True)['X']
nViews = len(X) # number of views
X = [X[i] for i in range(nViews)]
# compute XtX (2D list of size nViews*nViews, only upper triangle and diagonal are non-null since symmetric)
XtX = [[None for j in range(i)] + [X[i].T @ X[j] for j in range(i,nViews)] for i in range(nViews)]

# -----------------------------------------
# TODO: implement multiview_CCA_train function above
#       to compute CCA matrices and eigenvalues
A, L = multiview_CCA_train(XtX, CCAdim, nViews, featdim)

# -----------------------------------------
# TODO: compute shared representation Y
#
Y = X[0].dot(A[0])/nViews
for i in range(1, nViews):
    Y += X[i].dot(A[i])/nViews

Y = X[0]/nViews
for i in range(1, nViews):
    Y += X[i]/nViews

# "magic" weights on the p-th dimension: 1/sqrt(nViews-1-Lp)
# more weights on the top dimensions
CCA_weights = 1.0 / np.sqrt(nViews - 1 - L)
Y = Y * CCA_weights

# discard irrelavant data, only keep Y and CCA_weights
del X, XtX

#
# Nearest-neighbor word query
#
QueryFeature_small_data = loadmat(os.path.join(data_path, 'QueryFeature_small.mat'),
                                  simplify_cells=True)
GT_labels = QueryFeature_small_data['GT_labels'] - 1
Q = [QueryFeature_small_data['Q'][i] for i in range(nViews)]
topRetrievedLabels = []
numQueryToEvaluate = Q[0].shape[0]

k = 5 # top 5 retrieval results
for viewID in range(nViews):
    numQueries = Q[viewID].shape[0]
    query = Q[viewID]

    # query feature CCA projection
    CCACoef_q = query @ A[viewID]

    # perform exact nearest neighbor search
    queryImgFeat = CCACoef_q * CCA_weights
    # distance between query and database items
    distance = np.linalg.norm(queryImgFeat.reshape(numQueries,1,-1) - Y, axis=2)
    # distance = np.linalg.norm(query.reshape(numQueries,1,-1) - Y, axis=2)
    sortedIdx = distance.argsort()[:,:k]
    topRetrievedLabels.append(sortedIdx.T)

#
# Evaluate accuracy
#
accuracy = np.stack([(topRetrievedLabels[viewID][0] == GT_labels[:numQueryToEvaluate]).mean() for viewID in range(nViews)], 0)
print(f'Mean Accuracy: {accuracy.mean() * 100:.1f}%')

#  -----------------------------------------
#  TODO: use the more naive shared representation Y
#  which is the average of X[i]'s i=1,2,3. 
#  modify the query code above and report mean accuracy.
#  Hint: queryImgFeat is just Q[viewId] in this case.
#
