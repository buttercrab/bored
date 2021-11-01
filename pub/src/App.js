import React, { useEffect, useState } from "react";
import { HashRouter as Router } from "react-router-dom";

const width = 20,
  height = 7;
const num = width * height;

function App() {
  const [records, setRecords] = useState([]);
  const [users, setUsers] = useState([]);
  const [tier, setTier] = useState({ low: "", high: "" });
  const [todayProb, setTodayProb] = useState(1000);

  useEffect(() => {
    fetch("/api/v1/records")
      .then((res) => res.json())
      .then((res) => {
        if (res.success) {
          setTodayProb(res.at(-1).prob_id);
          setRecords(res.slice(Math.max(0, num - res.size), res.size));
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

  const rowRender = (rowRecord, col) => {
    const result = [];
    for (let i = 0; i < width; i++) {
      const tdStyle = {
        backgroundImage: "url(/images/0.png)",
        backgroundRepeat: "no-repeat",
        backgroundSize: "20px",
      };
      console.log(rowRecord.length);
      if (i >= rowRecord.length) {
        result.push(<td id={col +","+ i} style={tdStyle}/>);
      } else {
        tdStyle.backgroundImage = "url(/images/" + rowRecord[i].user + ".png)";
        result.push(
          <a href={"https://www.acmicpc.net/problem/" + rowRecord[i].prob_id}>
            <td id={i} style={tdStyle}/>
            <p class="arrow_box">{rowRecord[i].date}</p>
          </a>
        );
      }
    }
    return result;
  };

  const tableRender = () => {
    const result = [];
    for (let i = 0; i < height; i++) {
      if (i * width >= records.length) result.push(<tr id={i}>{rowRender([], i)}</tr>);
      else
        result.push(
          <tr id={i}>
            {rowRender(
              records.splice(i * width, Math.min(num, (i + 1) * width)), i
            )}
          </tr>
        );
    }
    return result;
  };

  return (
    <Router>
      <div className="title">Bored!</div>
      <div className="prob_container">
        <div className="today_prob">
          <h2 className="problem">
            <a href={"https://www.acmicpc.net/problem/" + todayProb}>
              {todayProb}
            </a>
          </h2>
          <h2 className="tier">{tier.low + "~" + tier.high}</h2>
        </div>
      </div>
      <div className="members">
        <table className="today_table">
          {users.map((name) => (
            <tr id={name}>
              <td>{name}</td>
            </tr>
          ))}
        </table>
      </div>
      <div className="tracker">{tableRender()}</div>
    </Router>
  );
}

export default App;
