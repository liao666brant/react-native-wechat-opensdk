import React from 'react';
import { Text, View, StyleSheet } from 'react-native';
import * as Wechat from 'react-native-wechat-opensdk';

// const result = multiply(3, 7);

export default function App() {
  const [YN, setYN] = React.useState(false);

  React.useEffect(() => {
    init();
  }, []);

  async function init() {
    const YN = await Wechat.isAppInstalled();
    console.log(11111);
    setYN(YN);
  }

  return (
    <View style={styles.container}>
      <Text>Result: {YN ? 'yes' : 'no'}</Text>
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
