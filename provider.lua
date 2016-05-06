require 'nn';
require 'image';
require 'xlua';

local Provider = torch.class 'Provider'

function Provider:__init()
    local cifarPath = 'data/'
    local trsize = 50000
    local tesize = 10000

    self.trainData = {
        data = torch.Tensor(50000, 3072),
        labels = torch.Tensor(50000),
        size = function() return trsize end
    }

    local trainData = self.trainData
    for i = 0,4 do
        local subset = torch.load(cifarPath..'cifar-10-batches-t7/data_batch_' .. (i+1) .. '.t7', 'ascii')
        trainData.data[{ {i*10000+1, (i+1)*10000} }] = subset.data:t()
        trainData.labels[{ {i*10000+1, (i+1)*10000} }] = subset.labels
    end
    trainData.labels = trainData.labels + 1

    local subset = torch.load(cifarPath..'cifar-10-batches-t7/test_batch.t7', 'ascii')
    self.testData = {
        data = subset.data:t():double(),
        labels = subset.labels[1]:double(),
        size = function() return tesize end
    }
    local testData = self.testData
    testData.labels = testData.labels + 1

    -- resize dataset (if using small version)
    trainData.data = trainData.data[{ {1,trsize} }]
    trainData.labels = trainData.labels[{ {1,trsize} }]

    testData.data = testData.data[{ {1,tesize} }]
    testData.labels = testData.labels[{ {1,tesize} }]

    -- reshape data
    trainData.data = trainData.data:reshape(trsize,3,32,32)
    testData.data = testData.data:reshape(tesize,3,32,32)
end