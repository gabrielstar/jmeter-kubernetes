#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir="`pwd`"

#Get namesapce variable
tenant="jubernetes2"
jmx="cloudssky.jmx"


test_name="$(basename "$jmx")"
#delete evicted pods first
kubectl get pods --all-namespaces --field-selector 'status.phase==Failed' -o json | kubectl delete -f -
#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep Running | grep jmeter-master | awk '{print $1}'`

kubectl cp "$jmx" -n $tenant "$master_pod:/$test_name"

## Echo Starting Jmeter load test

threads=$1
kubectl exec -ti -n $tenant $master_pod -- /bin/bash /load_test "$test_name" -Gthreads="$threads"
