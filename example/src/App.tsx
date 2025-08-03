import React from 'react';
import {Text, View, StyleSheet, Pressable} from 'react-native';
import * as Wechat from 'react-native-wechat-opensdk';

// const result = multiply(3, 7);

export default function App() {
  const [YN, setYN] = React.useState(false);

  React.useEffect(() => {
    init();
  }, []);

  async function init() {
    const YN = await Wechat.isAppInstalled();
    setYN(YN);
  }

  async function shareText(){
    await Wechat.shareText({
      text: '是丹江口市大家反馈',
    })
  }

  return (
    <View style={styles.container}>
      <Text>Result: {YN ? 'yes' : 'no'}</Text>

      <Pressable onPress={() => shareText()}><Text>分享文字</Text></Pressable>
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
