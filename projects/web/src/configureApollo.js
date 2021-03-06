import { ApolloClient } from 'apollo-client';
import { HttpLink } from 'apollo-link-http';
import { ApolloLink, concat } from 'apollo-link';
// eslint-disable-next-line
import { InMemoryCache } from 'apollo-cache-inmemory';

import { auth } from './utils';

const { REACT_APP__API_URL: API_URL } = process.env;

export default function configureApollo() {
  const httpLink = new HttpLink({
    uri: API_URL,
  });

  const authMiddleware = new ApolloLink((operation, forward) => {
    operation.setContext({
      headers: {
        authorization: auth.getToken(),
      },
    });

    return forward(operation);
  });

  return new ApolloClient({
    link: concat(authMiddleware, httpLink),
    cache: new InMemoryCache(),
  });
}
