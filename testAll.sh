for f in ./generated/*.thm; do
  abella "$f" |  tail -3 > "$f".result
done

counter=0
for f in ./generated/*.result; do
  if grep -q -e "Proof Completed" -e "Proof completed" "$f" 
  then 
	  echo "" >> "$f"
  else 
	  echo "Proof error: " "$f"
	  let counter++
  fi
done

rm ./generated/*.result

if [ "$counter" -gt 0 ];
	then
		echo "The proofs above throw an error."
	else
		echo "All proofs are successful."
fi