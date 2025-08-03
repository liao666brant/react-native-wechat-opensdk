import React from 'react';
import {Text, View, StyleSheet, Pressable} from 'react-native';
import * as Wechat from 'react-native-wechat-opensdk';

export default function App() {
  const [YN, setYN] = React.useState(false);

  const result = Wechat.multiply(3, 8);

  React.useEffect(() => {
    init();
  }, []);

  async function init() {
    const YN = await Wechat.registerApp('wx1ad80ac9a07dceef', 'https://app.51wopai.com/api/');
    setYN(YN);
  }

  async function shareText(){
    // await Wechat.openApp();
    // return;
    // await Wechat.shareFile({
    //   url: 'https://img.51wopai.com/storage/upload/2023/12/14/WqvFZiTk6DU2ctoy2SGr5YXG1u5oGRTVzovrgp0e.jpg',
    //   title: '是大丰收',
    //   ext: 'jpg',
    // })

    const res = await Wechat.auth({
      scope: 'snsapi_userinfo',
      state: "123",
    })
    console.log('222返回值', res)
  }

  return (
    <View style={styles.container}>
      <Text style={{color: '#FFFFFF'}}>Result: {result}</Text>
      <Text style={{color: '#FFFFFF'}}>Result: {YN ? 'yes' : 'no'}</Text>

      <Pressable onPress={() => shareText()}><Text style={{color: '#FFFFFF'}}>分享文字</Text></Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
