fsum = function(x){
  rs = rowSums(x[,7:16])
  es = rowSums(x[,17:69])
  #fs = rowSums(x[,70:455])
  ss = rs+es
  x = cbind(x,rs,es,ss)
  x
}
submit = function(pred,id){
  output = matrix(pred,3,length(id))
  output = (t(output))
  head(output)
  output = as.data.frame(output)
  output$id = id
  output = output[,c(4,1,2,3)]
  outputHeader = c("id","predict_0","predict_1","predict_2")
  names(output) = outputHeader
  output
}


