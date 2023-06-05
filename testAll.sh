for f in ./generated/*.thm; do
  abella "$f" |  tail -3 > "$f".result
done

counter=0
for f in ./generated/*.result; do
  if grep -q -e "error:" -e "error:" "$f" 
  then 
	  echo "Proof error: " "$f"
	  let counter++
  else 
	  echo "" >> "$f"
  fi
done

rm ./generated/*.result

if [ "$counter" -eq 0 ];
	then
		echo "All proofs are successful."
	else
		echo "The proofs above throw an error."
fi