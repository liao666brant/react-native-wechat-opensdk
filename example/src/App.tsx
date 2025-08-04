import React from 'react';
import {Text, View, StyleSheet, Pressable} from 'react-native';
import Wechat from 'react-native-wechat-opensdk';

export default function App() {
  const [YN, setYN] = React.useState(false);

  const result = Wechat.multiply(3, 7);

  React.useEffect(() => {
    init();
  }, []);

  async function init() {
    await Wechat.registerApp('wx1ad80ac9a07dceef', 'https://app.51wopai.com/api/');
    const YN = await Wechat.isAppInstalled();
    setYN(YN);
  }

  async function shareText(){
    // await Wechat.openApp();
    // return;
    // const res = await Wechat.shareFile({
    //   url: 'https://reactnative.dev/docs/assets/turbo-native-modules/c++visualstudiocode.webp',
    // })

    // const res = await Wechat.auth({
    //   scope: 'snsapi_userinfo',
    //   state: "123",
    // })
    const res = await Wechat.shareText({
      text: "分享文本",
    })
    // const res = await Wechat.shareImage({
    //   imageUrl: "https://reactnative.dev/docs/assets/turbo-native-modules/c++visualstudiocode.webp",
    // })
    // const res = await Wechat.shareVideo({
    //   videoUrl: "https://reactnative.dev/docs/assets/turbo-native-modules/c++visualstudiocode.webp",
    //   title: '水淀粉',
    // })
    console.log('222返回值', res)
  }

  return (
    <View style={styles.container}>
      <Text style={{color: '#FF0000'}}>Result: {result}</Text>
      <Text style={{color: '#FF0000'}}>Result: {YN ? 'yes' : 'no'}</Text>

      <Pressable onPress={() => shareText()}><Text style={{color: '#FF0000'}}>分享文字</Text></Pressable>
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
