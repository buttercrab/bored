import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";

function App() {
  const [probId, setProbId] = useState(1000);
  const [users, setUsers] = useState([]);
  const [tier, setTier] = useState({ low: "", high: "" });

  useEffect(() => {
    fetch("/api/v1/problem")
      .then((res) => res.json())
      .then((res) => {
        if (res.success) {
          setProbId(res.prob_id);
        } else {
          // error
        }
      });
    fetch("/api/v1/users")
      .then((res) => res.json())
      .then((res) => {
        if (res.success) {
          setUsers(res);
        } else {
          // error
        }
      });
    fetch("/api/v1/tier")
      .then((res) => res.json())
      .then((res) => {
        if (res.success) {
          setTier({ low: res.low, high: res.high });
        } else {
          // error
        }
      });
  }, []);

  return (
    <>
      <Link to={"https://www.acmicpc.net/problem/" + probId}>
        <div className="problem">{probId}</div>
      </Link>
      <div className="tier">{tier.low+"~"+tier.high}</div>
    </>
  );
}
