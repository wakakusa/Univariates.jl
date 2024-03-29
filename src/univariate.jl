function numericsummary(INPUT::Union{Array,DataFrame},VarNames::Symbol)  #数値型の基本統計量の算出
  SummaryVar=StatsBase.var(INPUT)
  SummaryStd=StatsBase.std(INPUT)
  SummaryQuartile=StatsBase.quantile( INPUT , [0.00, 0.25, 0.50, 0.75, 1.00])
  SummaryMedian=StatsBase.median(INPUT)
  SummaryMean=StatsBase.mean(INPUT)

  Output=DataFrame(colname=VarNames,Var=SummaryVar,Std=SummaryStd,Mean=SummaryMean, Min=SummaryQuartile[1] ,Quartile1st=SummaryQuartile[2] ,Median=SummaryMedian,Quartile3rd=SummaryQuartile[4],Max=SummaryQuartile[5])

  return Output
end

function nonnumericsummary(INPUT::Union{Array,DataFrame},VarNames::Symbol)  #非数値型の基本統計量の算出
  Output=combine(groupby(INPUT, VarNames, sort=false, skipmissing=false), VarNames=>df -> size(df, 1))
  rename!(Output,[VarNames,:count])

  return Output
end

function summarymerge(INPUT::DataFrame, Summary::DataFrame ,FirstMergeFlag::Bool)  #データの集約
  if FirstMergeFlag ==true
    Summary=INPUT
    FirstMergeFlag=false
  else
    Summary=vcat(Summary,INPUT)
  end

  return Summary,FirstMergeFlag
end

function univariate(INPUT::DataFrame;graphplot::Bool=false)
  VarNames=propertynames(INPUT)
  Vartype=eltype.(eachcol(INPUT))
  SummaryNonNum=DataFrame(colname="",hist=0)
  SummaryNum=DataFrame(colname="",Var=0.0,Std=0.0,Mean=0.0, Min=0.0 ,Quartile1st=0.0 ,Median=0.0,Quartile3rd=0.0,Max=0.0)
  FirstMergeFlagNum=true
  FirstMergeFlagNonNum=true
  typearray=0
  typearrayflag=true
 
  for  i = 1 : size(INPUT,2)
    if Vartype[i] <: Real
      #数値型の基本統計量の算出
      work=numericsummary(INPUT[:,i],VarNames[i])

      #基本統計量の集約
      SummaryNum,FirstMergeFlagNum=summarymerge(work,SummaryNum,FirstMergeFlagNum)
      #列がReal型かどうか判定
      if typearrayflag
        typearray=i
        typearrayflag=false
      else
        typearray=hcat(typearray,i)
      end
    else
      #非数値型の基本統計量の算出
      work=nonnumericsummary(INPUT,VarNames[i])
      
      #基本統計量の集約
      SummaryNonNum,FirstMergeFlagNonNum=summarymerge(work,SummaryNonNum,FirstMergeFlagNonNum)
    end   
  end

  if(graphplot)
   # gr()
   # @df INPUT corrplot(cols(typearray),grid=true)
  end

  return SummaryNum,SummaryNonNum
end
