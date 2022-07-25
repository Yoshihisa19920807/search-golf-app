import React, { Key } from 'react';

import './Common.css';
import "react-datepicker/dist/react-datepicker.css"
import DatePicker, { registerLocale } from "react-datepicker";
import ja from 'date-fns/locale/ja';
import axios from 'axios';
import addDays from 'date-fns/addDays';

import Result from './Result';
import Loading from './Loading';

export type Plan = {
  plan_id: Key;
  image_url: string;
  course_name: string;
  duration: string;
  price: string;
  evaluation: string;
  prefecture: string;
  plan_name: string;
  caption: string;
  reserve_url_pc: string;
};

const Home = () => {
  const Today = new Date();
  const [date, setDate] = React.useState<Date>(Today);
  const [budget, setBudget] = React.useState<number>(8000);
  const [departure, setDeparture] = React.useState<number>(1);
  const [duration, setDuration] = React.useState<number>(60);
  const [plans, setPlans] = React.useState<Plan[]>([])
  const [planCount, setPlanCount] = React.useState<number | undefined>(undefined);
  const [hasError, setHasError] = React.useState<boolean>(false);
  const [loading, setLoading] = React.useState<boolean>(false);
  registerLocale('ja', ja);
  // voidは何も返す値がないことを表す返り値
  const onFormSubmit = async (event: { preventDefault: () => void; }) => {
    setLoading(true);
    // await sleep(1000);
    // await setTimeout(()=>{console.log("timeout")}, 10000);
    try {
    // <form>タグを使うと、ボタンを押した際にデフォルトでonSubmitイベントが走ります。今回は、onSubmitイベントが走ったら、自分で作ったonFormSubmit関数を実行したいため、こちらの記述でデフォルトのsubmit処理をキャンセルしています。参考：https://developer.mozilla.org/ja/docs/Web/API/Event/preventDefault
    event.preventDefault();
    // const response = await axios.get('http://localhost:3001/comments/1', {
    const response = await axios.get('https://l1kwik11ne.execute-api.ap-northeast-1.amazonaws.com/production/golf-courses', {
      params: { date: addDays(date, 14), budget: budget, departure: departure, duration: duration }
    });

    console.log(addDays(date, 14), budget, departure, duration)
    console.log(response);
    setPlans(response.data.plans);
    setPlanCount(0);
    setLoading(false);
    // setPlanCount(response.data.count);
    } catch (e) {
      console.log(e);
      setHasError(true);
    }
  }

  return (
    <div className="ui container" id="container">
      <div className="Search__Form">
        <form className="ui form segment" onSubmit={onFormSubmit}>
          <div className="field">
            <label>
              <i className="calendar alternate outline icon"></i>
              プレー日
              <DatePicker
                onChange={selectedDate => {setDate(selectedDate || Today)}}
                selected={date}
                dateFormat="yyyy/MM/dd"
                locale='ja'
                minDate={Today}
              />
            </label>
            <div className="field">
            <label>
              <i className="yen sign icon"></i>
              上限金額
            </label>
            <select
              className="ui dropdown"
              name="dropdown"
              value={budget}
              onChange={(e) => setBudget(Number(e.target.value))}
            >
              <option value="8000">8,000円</option>
              <option value="12000">12,000円</option>
              <option value="16000">16,000円</option>
            </select>
            </div>
          </div>
          <div className="field">
            <label>
              <i className="map pin icon"></i>
              移動時間計算の出発地点（自宅近くの地点をお選びください）
              <select
                className="ui dropdown"
                name="dropdown"
                value={departure}
                onChange={(e) => setDeparture(Number(e.target.value))}
              >
                <option value="1">東京駅</option>
                <option value="2">横浜駅</option>
              </select>
            </label>
          </div>
          <div className="filed">
            <label>
              <i className="car icon"></i>
              車での移動時間の上限
            </label>
            <select
              className="ui dropdown"
              name="dropdown"
              value={duration}
              onChange={(e) => setDuration(Number(e.target.value))}
            >
              <option value="60">60分</option>
              <option value="90">90分</option>
              <option value="120">120分</option>
            </select>
          </div>
          <div className="Search__Button">
            <button type="submit" className="Search__Button__Design">
              <i className="search icon"></i>
              ゴルフ場を検索する
            </button>
          </div>
        </form>
        <Loading loading={loading} />
        <Result
          plans={plans}
          planCount={planCount}
          hasError={hasError}
        />
      </div>
    </div>
  );
}

export default Home;

// function sleep(arg0: number) {
//   throw new Error('Function not implemented.');
// }
