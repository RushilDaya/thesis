function acc = rd_computeAccuracy( rowA,rowB )

errorCount = sum(abs(rowA-rowB));
acc = (size(rowA,1)-errorCount)/size(rowA,1);
acc = 100*acc;


end

